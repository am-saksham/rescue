import React from 'react';
import { Link } from 'react-router-dom';
import backgroundImage from '../assets/hpbgimage.jpeg';

function HomePage() {
  return (
    <div
      className="flex flex-col items-center justify-center w-full h-full min-h-screen text-white"
      style={{
        backgroundImage: `url(${backgroundImage})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
      }}
    >
      <div className="bg-black bg-opacity-50 p-8 rounded-lg text-center mb-8">
        <h1 className="text-5xl font-extrabold tracking-wide">RESCUE</h1>
      </div>
      <div className="space-y-4">
        <Link to="/help-me">
          <button className="bg-white text-blue-500 py-3 px-6 rounded-full shadow-lg hover:bg-blue-100 transition duration-300">
            Help me!
          </button>
        </Link>
        <Link to="/i-want-to-help">
          <button className="border border-white py-3 px-6 rounded-full shadow-lg hover:bg-white hover:text-blue-500 transition duration-300">
            I want to help.
          </button>
        </Link>
      </div>
    </div>
  );
}

export default HomePage;