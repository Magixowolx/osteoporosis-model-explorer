import { useState } from 'react'
import { useEffect } from 'react'
import './App.css'

function App() {
  async function fetchPrediction() {
    const response = await fetch('http://localhost:8000/predict', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        cutoff: 'sens90',
        age: 65,
        height: 170,
        weight: 70,
        menopause_age: 50
      })
    });

    const result = await response.json();
    console.log(result);
  }

  return (
    <div>
      <h1>Osteoporosis Model Explorer</h1>
      <button onClick={fetchPrediction}>Fetch Prediction</button>
    </div>
  );
}
export default App
