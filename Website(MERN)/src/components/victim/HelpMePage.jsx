import React from 'react';
import { useNavigate } from 'react-router-dom';

function HelpMePage() {
  const navigate = useNavigate();

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100 text-black">
      <div className="w-full h-full max-w-none p-12 bg-white shadow-lg rounded-lg">
        <div className="flex justify-between items-center mb-8">
          <button className="text-2xl">&#x2190;</button>
          <h1 className="text-3xl font-bold">RESCUE</h1>
          <div className="text-2xl">☰</div>
        </div>
        <div className="flex justify-center items-center mb-10">
          <div className="w-16 h-16 bg-black text-white flex items-center justify-center rounded-full text-3xl">
            1
          </div>
        </div>
        <h2 className="text-center text-2xl font-semibold mb-6">WHAT IS THE EMERGENCY?</h2>
        <div className="grid grid-cols-2 gap-6">
          {['Earthquake', 'Fire', 'Floods', 'Tsunami', 'Landslide', 'Stampede', 'Other'].map((emergency) => (
            <button
              key={emergency}
              onClick={() => navigate('/victim-info')}
              className="py-4 bg-black text-white rounded-full hover:bg-gray-800 transition duration-300"
            >
              {emergency}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

export default HelpMePage;
