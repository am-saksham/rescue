import React from 'react';

function HelpType() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="bg-white p-12 rounded-lg shadow-lg w-full max-w-2xl">
        <div className="flex justify-between items-center mb-8">
          <button className="text-2xl">&#x2190;</button>
          <h1 className="text-3xl font-bold">RESCUE</h1>
          <div className="text-2xl">☰</div>
        </div>
        <div className="flex justify-center items-center mb-10">
          <div className="w-16 h-16 bg-black text-white flex items-center justify-center rounded-full text-3xl">
            3
          </div>
        </div>
        <h2 className="text-center text-2xl font-semibold mb-6">WHAT DO YOU NEED?</h2>
        <div className="space-y-4">
          {[
            { label: 'Medical Assistance', icon: '🩺' },
            { label: 'Food and Water', icon: '🥤' },
            { label: 'Shelter', icon: '🏕️' },
            { label: 'Evacuation', icon: '🚐' },
            { label: 'Other', icon: '❓' },
          ].map((help) => (
            <div key={help.label} className="flex items-center space-x-4">
              <div className="w-12 h-12 flex items-center justify-center border border-black rounded-full">
                {help.icon}
              </div>
              <span className="text-lg">{help.label}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default HelpType;
