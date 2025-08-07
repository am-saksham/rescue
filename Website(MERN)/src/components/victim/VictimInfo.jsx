import React from 'react';
import { useNavigate } from 'react-router-dom';

function VictimInfo() {
  const navigate = useNavigate();

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100">
      <form
        className="bg-white p-12 rounded-lg shadow-lg w-full max-w-2xl"
        onSubmit={(e) => {
          e.preventDefault();
          navigate('/help-type');
        }}
      >
        <div className="flex justify-between items-center mb-8">
          <button className="text-2xl">&#x2190;</button>
          <h1 className="text-3xl font-bold">RESCUE</h1>
          <div className="text-2xl">☰</div>
        </div>
        <div className="flex justify-center items-center mb-10">
          <div className="w-16 h-16 bg-black text-white flex items-center justify-center rounded-full text-3xl">
            2
          </div>
        </div>
        <div className="mb-4">
          <label className="block text-lg font-semibold mb-2">Name:</label>
          <input type="text" className="w-full p-3 border border-black rounded-full" />
        </div>
        <div className="mb-4">
          <label className="block text-lg font-semibold mb-2">Location:</label>
          <input type="text" className="w-full p-3 border border-black rounded-full" />
          <p className="text-sm text-gray-500 mt-1">📍 Track my location</p>
        </div>
        <div className="mb-6">
          <label className="block text-lg font-semibold mb-2">Personalised Message:</label>
          <textarea className="w-full p-3 border border-black rounded-lg" rows="4"></textarea>
        </div>
        <button type="submit" className="w-full bg-black text-white py-3 rounded-full hover:bg-gray-800 transition duration-300">
          Send to All Volunteers
        </button>
      </form>
    </div>
  );
}

export default VictimInfo;