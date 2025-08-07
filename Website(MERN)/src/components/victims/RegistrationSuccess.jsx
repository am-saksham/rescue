import React from 'react';

function RegistrationSuccess() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-r from-green-500 to-blue-600">
      <div className="bg-white p-10 rounded-lg shadow-lg w-full max-w-md text-center">
        <h2 className="text-3xl font-bold mb-4">Registration Successful!</h2>
        <p className="mb-6">Thank you for registering as a volunteer. We will contact you soon!</p>
        <button className="bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition duration-300">
          Go to Home
        </button>
      </div>
    </div>
  );
}

export default RegistrationSuccess;
