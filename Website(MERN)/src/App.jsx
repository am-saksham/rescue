import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import HomePage from './components/HomePage';
import HelpMePage from './components/victim/HelpMePage';
import IWantToHelpPage from './components/agent/IWantToHelpPage';
import VictimInfo from './components/victim/VictimInfo';
import HelpType from './components/victim/HelpType';
import RegistrationSuccess from './components/victims/RegistrationSuccess';


function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/help-me" element={<HelpMePage />} />
        <Route path="/i-want-to-help" element={<IWantToHelpPage />} />
        <Route path="/victim-info" element={<VictimInfo />} />
        <Route path="/help-type" element={<HelpType />} />
        <Route path="/registration-success" element={<RegistrationSuccess />} />
      </Routes>
    </Router>
  );
}

export default App;