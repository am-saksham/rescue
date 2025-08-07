import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
// import RegistrationSuccess from '../victim/RegistrationSuccess';

function IWantToHelpPage() {
  const [otp, setOtp] = useState('');
  const [profilePicture, setProfilePicture] = useState(null);
  const [profilePictureUrl, setProfilePictureUrl] = useState('');
  const navigate = useNavigate();

  const handleOtpChange = (e) => {
    setOtp(e.target.value);
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file && file.type === 'image/png') {
      setProfilePicture(file);
      setProfilePictureUrl(URL.createObjectURL(file));
    } else {
      alert('Please upload a PNG image.');
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // Here you can add any form submission logic if needed
    navigate('/registration-success'); // Navigate to the success page
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-r from-blue-500 to-purple-600">
      <form className="bg-white p-10 rounded-lg shadow-lg w-full max-w-2xl" onSubmit={handleSubmit}>
        <h2 className="text-3xl font-bold text-center mb-6">Volunteer Registration</h2>
        
        <div className="mb-4">
          <label className="block text-lg font-semibold mb-2">Name:</label>
          <input type="text" className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
        
        <div className="mb-4">
          <label className="block text-lg font-semibold mb-2">Email:</label>
          <input type="email" className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
        
        <div className="mb-4">
          <label className="block text-lg font-semibold mb-2">Phone:</label>
          <input type="tel" className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" />
        </div>
        
        <div className="mb-4">
          <label className="block text-lg font-semibold mb-2">Aadhaar Number:</label>
          <input type="text" className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" />
          <div className="flex items-center mt-2">
            <button type="button" className="bg-blue-600 text-white py-1 px-3 rounded-lg hover:bg-blue-700 transition duration-300">
              Send OTP
            </button>
            <input 
              type="text" 
              value={otp} 
              onChange={handleOtpChange} 
              placeholder="Enter OTP" 
              className="ml-2 w-1/2 p-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" 
            />
          </div>
        </div>

        <div className="mb-4">
          <label className="block text-lg font-semibold mb-2">Location:</label>
          <input type="text" className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Enter your location" />
        </div>

        <div className="mb-4">
          <label className="block text-lg font-semibold mb-2">Profile Picture (PNG):</label>
          <input 
            type="file" 
            accept=".png" 
            onChange={handleFileChange} 
            className="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" 
          />
          {profilePictureUrl && (
            <div className="mt-4">
              <img src={profilePictureUrl} alt="Profile Preview" className="w-24 h-24 object-cover rounded-full border border-gray-300" />
            </div>
          )}
        </div>
        
        <div className="mb-6">
          <label className="block text-lg font-semibold mb-2">Types of Help You Can Provide:</label>
          <div className="flex flex-col space-y-2">
            {['Medical Assistance', 'Food Distribution', 'Shelter Provision', 'Transportation', 'Other'].map((help) => (
              <label key={help} className="flex items-center">
                <input type="checkbox" className="mr-2 h-5 w-5 text-blue-600 border-gray-300 rounded focus:ring-blue-500" />
                <span className="text-lg">{help}</span>
              </label>
            ))}
          </div>
        </div>
        
        <button type="submit" className="w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700 transition duration-300">
          Register
        </button>
      </form>
    </div>
  );
}

export default IWantToHelpPage;
