import streamlit as st
import numpy as np
import random
import time
import pandas as pd
import folium
from streamlit_folium import st_folium
import math

# Campus dimensions (50x50 meters - about half a football field)
CAMPUS_WIDTH = 50  # meters
CAMPUS_HEIGHT = 50  # meters
AGENT_STEP_SIZE = 2  # meters per move
DETECTION_RADIUS = 3  # meters

# VIT Bhopal coordinates (approx)
UNIVERSITY_CENTER = [23.2745, 77.4185]

class RescueSimulation:
    def __init__(self):
        # Initialize parameters
        self.num_agents = 5  # 5 agents
        self.learning_rate = 0.1
        self.discount_factor = 0.9
        self.exploration_rate = 0.3
        self.map_zoom = 19  # Max zoom level
        
        # Initialize data structures
        self.agent_positions = {}
        self.target_positions = []
        self.obstacles = []
        self.agent_stats = {}
        self.path_history = {}
        self.q_tables = {}
        
        # Initialize positions and Q-tables
        self.initialize_positions()
        
        # Simulation metrics
        self.start_time = None
        self.time_taken = None

    def initialize_positions(self):
        """Initialize positions within 50x50 meter campus"""
        # Initialize agents at random positions
        self.agent_positions = {
            f"rescue{i+1}": np.array([
                random.randint(5, CAMPUS_WIDTH-5),
                random.randint(5, CAMPUS_HEIGHT-5)
            ]) for i in range(self.num_agents)
        }
        
        # Initialize Q-tables
        self.q_tables = {agent: {} for agent in self.agent_positions}
        
        # Initialize stats
        self.agent_stats = {
            agent: {
                "targets_rescued": 0,
                "distance_covered": 0,
                "status": "🟢 Active",
                "battery": 100,
                "last_action": None,
                "last_state": None
            } for agent in self.agent_positions
        }
        
        # Initialize path history
        self.path_history = {
            agent: [tuple(pos)] for agent, pos in self.agent_positions.items()
        }

    def set_victim_locations(self, locations):
        self.target_positions = locations
        self.target_status = {f"target{i+1}": "🟢 Active" for i in range(len(locations))}

    def set_obstacles(self, obstacles):
        self.obstacles = obstacles

    def get_state(self, agent_pos):
        """Convert position to discrete state (2 meter grid)"""
        return (round(agent_pos[0]/2)*2, (round(agent_pos[1]/2)*2))

    def get_possible_actions(self):
        """8 possible movement directions (2 meters each)"""
        angles = [0, 45, 90, 135, 180, 225, 270, 315]
        return [
            (AGENT_STEP_SIZE * math.cos(math.radians(angle)), 
             AGENT_STEP_SIZE * math.sin(math.radians(angle)))
            for angle in angles
        ]

    def choose_action(self, agent, state):
        """Epsilon-greedy action selection"""
        possible_actions = self.get_possible_actions()
        
        if random.random() < self.exploration_rate:
            return random.choice(possible_actions)
        
        if state not in self.q_tables[agent]:
            self.q_tables[agent][state] = {action: 0 for action in possible_actions}
        
        max_q = max(self.q_tables[agent][state].values())
        best_actions = [a for a, q in self.q_tables[agent][state].items() if q == max_q]
        return random.choice(best_actions)

    def calculate_reward(self, agent, new_pos):
        """Calculate reward for moving to new position"""
        reward = 0
        
        # Check if reached target
        for target in self.target_positions:
            if np.linalg.norm(np.array(target) - new_pos) < DETECTION_RADIUS:
                reward += 100
                break
        
        # Penalty for hitting obstacle
        for obstacle in self.obstacles:
            if np.linalg.norm(np.array(obstacle) - new_pos) < DETECTION_RADIUS:
                reward -= 50
                break
        
        # Small penalty for moving
        reward -= 1
        
        # Reward for moving toward nearest target
        if self.target_positions:
            nearest_target = min(self.target_positions, 
                               key=lambda t: np.linalg.norm(np.array(t) - new_pos))
            old_dist = np.linalg.norm(np.array(nearest_target) - self.agent_positions[agent])
            new_dist = np.linalg.norm(np.array(nearest_target) - new_pos)
            if new_dist < old_dist:
                reward += 5
        
        return reward

    def move_agents(self):
        """Move agents using Q-learning in campus grid"""
        for agent in self.agent_positions:
            if self.agent_stats[agent]["status"] == "🏁 Reached":
                continue
                
            current_pos = self.agent_positions[agent]
            state = self.get_state(current_pos)
            action = self.choose_action(agent, state)
            new_pos = current_pos + np.array(action)
            
            # Ensure within campus bounds
            new_pos[0] = max(0, min(new_pos[0], CAMPUS_WIDTH))
            new_pos[1] = max(0, min(new_pos[1], CAMPUS_HEIGHT))
            
            reward = self.calculate_reward(agent, new_pos)
            new_state = self.get_state(new_pos)
            
            # Initialize Q-values if needed
            if state not in self.q_tables[agent]:
                self.q_tables[agent][state] = {a: 0 for a in self.get_possible_actions()}
            if new_state not in self.q_tables[agent]:
                self.q_tables[agent][new_state] = {a: 0 for a in self.get_possible_actions()}
            
            # Q-learning update
            max_next_q = max(self.q_tables[agent][new_state].values())
            self.q_tables[agent][state][tuple(action)] = (1 - self.learning_rate) * self.q_tables[agent][state][tuple(action)] + \
                                                      self.learning_rate * (reward + self.discount_factor * max_next_q)
            
            # Update position and stats
            self.agent_positions[agent] = new_pos
            self.path_history[agent].append(tuple(new_pos))
            dist_covered = np.linalg.norm(np.array(action))
            self.agent_stats[agent]["distance_covered"] += dist_covered
            self.agent_stats[agent]["battery"] -= dist_covered * 0.5  # 0.5% per 2 meters
            
            if self.agent_stats[agent]["battery"] < 0:
                self.agent_stats[agent]["battery"] = 0
                self.agent_stats[agent]["status"] = "🔴 Dead"
            
            # Check if target reached
            for target in list(self.target_positions):
                if np.linalg.norm(np.array(target) - new_pos) < DETECTION_RADIUS:
                    self.agent_stats[agent]["targets_rescued"] += 1
                    self.agent_stats[agent]["status"] = "🏁 Reached"
                    if "completion_time" not in self.agent_stats[agent]:
                        self.agent_stats[agent]["completion_time"] = time.time() - self.start_time
                    self.target_positions.remove(target)
                    break
        
        # Update time taken if all targets reached
        if not self.target_positions and self.start_time:
            self.time_taken = time.time() - self.start_time

def campus_to_gps(x, y):
    """Convert 50x50 meter campus coordinates to GPS"""
    # 0.00001° ≈ 1.11m, so we'll scale appropriately
    return [
        UNIVERSITY_CENTER[0] + (y - CAMPUS_HEIGHT/2) * 0.000018,  # ~1m per unit
        UNIVERSITY_CENTER[1] + (x - CAMPUS_WIDTH/2) * 0.000018
    ]

def create_campus_map(agent_positions, target_positions, obstacles, path_history, agent_stats):
    """Create Folium map showing campus area"""
    m = folium.Map(location=UNIVERSITY_CENTER, zoom_start=19, tiles="OpenStreetMap")
    
    # Add university marker
    folium.Marker(
        location=UNIVERSITY_CENTER,
        popup="VIT Bhopal University",
        icon=folium.Icon(color="green", icon="university")
    ).add_to(m)
    
    # Add campus boundary (50x50 meters)
    campus_bounds = [
        campus_to_gps(0, 0),
        campus_to_gps(CAMPUS_WIDTH, CAMPUS_HEIGHT)
    ]
    folium.Rectangle(
        bounds=campus_bounds,
        color='#3186cc',
        fill=True,
        fill_color='#3186cc',
        fill_opacity=0.2,
        weight=2
    ).add_to(m)
    
    # Add grid lines every 5 meters
    for x in range(0, CAMPUS_WIDTH+1, 5):
        folium.PolyLine(
            [campus_to_gps(x, 0), campus_to_gps(x, CAMPUS_HEIGHT)],
            color='gray',
            weight=0.5,
            opacity=0.5
        ).add_to(m)
    for y in range(0, CAMPUS_HEIGHT+1, 5):
        folium.PolyLine(
            [campus_to_gps(0, y), campus_to_gps(CAMPUS_WIDTH, y)],
            color='gray',
            weight=0.5,
            opacity=0.5
        ).add_to(m)
    
    # Add targets with larger markers
    for i, target in enumerate(target_positions):
        folium.CircleMarker(
            location=campus_to_gps(*target),
            radius=8,
            color='red',
            fill=True,
            fill_color='red',
            popup=f"Victim {i+1}"
        ).add_to(m)
    
    # Add obstacles
    for i, obstacle in enumerate(obstacles):
        folium.CircleMarker(
            location=campus_to_gps(*obstacle),
            radius=10,
            color='black',
            fill=True,
            popup=f"Obstacle {i+1}"
        ).add_to(m)
    
    # Add agents and paths with larger markers
    colors = ['blue', 'green', 'purple', 'orange', 'pink']
    for i, (agent, pos) in enumerate(agent_positions.items()):
        gps_path = [campus_to_gps(*p) for p in path_history[agent]]
        if len(gps_path) > 1:
            folium.PolyLine(
                gps_path,
                color=colors[i % len(colors)],
                weight=4,
                opacity=0.8
            ).add_to(m)
        
        folium.CircleMarker(
            location=campus_to_gps(*pos),
            radius=8,
            color=colors[i % len(colors)],
            fill=True,
            fill_color=colors[i % len(colors)],
            popup=f"{agent} (Battery: {agent_stats[agent]['battery']:.1f}%)"
        ).add_to(m)
    
    return m

# Streamlit App
st.set_page_config(page_title="VIT Campus Rescue", layout="wide")

# Initialize simulation
if 'sim' not in st.session_state:
    st.session_state.sim = RescueSimulation()
sim = st.session_state.sim

# Sidebar
with st.sidebar:
    st.header("Campus Rescue Mission")
    st.write(f"**Campus Area:** {CAMPUS_WIDTH}x{CAMPUS_HEIGHT} meters")
    st.write(f"**Agent Step Size:** {AGENT_STEP_SIZE} meters")
    
    # Victim locations
    st.subheader("Victim Locations")
    num_victims = st.number_input("Number of Victims", 1, 5, 2)
    victim_locations = []
    
    cols = st.columns(2)
    for i in range(num_victims):
        with cols[0]:
            x = st.number_input(f"X {i+1}", 0, CAMPUS_WIDTH, random.randint(10, 40))
        with cols[1]:
            y = st.number_input(f"Y {i+1}", 0, CAMPUS_HEIGHT, random.randint(10, 40))
        victim_locations.append([x, y])
    
    if st.button("Set Victim Locations"):
        sim.set_victim_locations(victim_locations)
        st.success(f"{num_victims} victims placed on campus!")
    
    # Obstacle locations
    st.subheader("Campus Obstacles")
    num_obstacles = st.number_input("Number of Obstacles", 0, 15, 5)
    obstacle_locations = []
    
    cols = st.columns(2)
    for i in range(num_obstacles):
        with cols[0]:
            x = st.number_input(f"Obstacle X {i+1}", 0, CAMPUS_WIDTH, random.randint(10, 40))
        with cols[1]:
            y = st.number_input(f"Obstacle Y {i+1}", 0, CAMPUS_HEIGHT, random.randint(10, 40))
        obstacle_locations.append([x, y])
    
    if st.button("Set Obstacles"):
        sim.set_obstacles(obstacle_locations)
        st.success(f"{num_obstacles} obstacles placed on campus!")
    
    # Learning parameters
    st.subheader("Learning Parameters")
    sim.learning_rate = st.slider("Learning Rate", 0.01, 0.5, 0.1)
    sim.discount_factor = st.slider("Discount Factor", 0.1, 0.99, 0.9)
    sim.exploration_rate = st.slider("Exploration Rate", 0.01, 1.0, 0.3)
    
    # Simulation control
    st.subheader("Mission Control")
    if st.button("Start Mission"):
        sim.start_time = time.time()
        st.rerun()
    
    if st.button("Reset Mission"):
        sim.__init__()
        st.rerun()

# Main content
st.title("🚨 VIT Bhopal Campus Rescue Simulator")
st.write(f"**Map Scale:** {CAMPUS_WIDTH}×{CAMPUS_HEIGHT} meters | **Detection Radius:** {DETECTION_RADIUS} meters")

# Campus map
m = create_campus_map(sim.agent_positions, sim.target_positions, sim.obstacles, sim.path_history, sim.agent_stats)
st_folium(m, width=1200, height=600)

# Progress
if sim.target_positions:
    progress = (1 - len(sim.target_positions)/num_victims) * 100
    st.progress(int(progress))
    st.caption(f"Mission Completion: {progress:.1f}%")
else:
    st.success("All campus victims rescued!")

# Agent status
st.subheader("Rescue Team Status")
if hasattr(sim, 'agent_stats'):
    status_data = []
    for agent, stats in sim.agent_stats.items():
        status_data.append({
            "Agent": agent,
            "Status": stats["status"],
            "Battery": f"{stats['battery']:.1f}%",
            "Distance": f"{stats['distance_covered']:.0f} meters",
            "Rescues": stats["targets_rescued"],
            "Position": f"({sim.agent_positions[agent][0]:.0f}, {sim.agent_positions[agent][1]:.0f})",
            "Time": f"{stats.get('completion_time', 0):.1f}s" if stats.get('completion_time') else "Active"
        })
    st.dataframe(pd.DataFrame(status_data).sort_values("Rescues", ascending=False), hide_index=True)

# Auto-update
if sim.start_time and sim.target_positions:
    time.sleep(0.3)
    sim.move_agents()
    st.rerun()