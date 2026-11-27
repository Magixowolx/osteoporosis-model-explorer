import { useState } from 'react'
import './App.css'

const outcomes = [
  { key: 'rightfn', label: 'Right femur' },
  { key: 'leftfn', label: 'Left femur' },
  { key: 'ls1', label: 'Lumbar spine 1' },
  { key: 'ls2', label: 'Lumbar spine 2' },
  { key: 'ls3', label: 'Lumbar spine 3' },
  { key: 'ls4', label: 'Lumbar spine 4' },
  { key: 'ls', label: 'Any lumbar spine' },
  { key: 'anydx', label: 'Any site' },
]

function App() {
  const [age, setAge] = useState('')
  const [height, setHeight] = useState('')
  const [weight, setWeight] = useState('')
  const [menopauseAge, setMenopauseAge] = useState('')
  const [cutoff, setCutoff] = useState('sens90')
  const [probabilities, setProbabilities] = useState(null)
  const [classifications, setClassifications] = useState(null)
  const [errorMessage, setErrorMessage] = useState('')

  async function fetchPrediction() {
    setErrorMessage(''); // Clear previous error message
    try {
      const response = await fetch('http://localhost:8000/predict', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          cutoff: cutoff,
          age: age,
          height: height,
          weight: weight,
          ...(menopauseAge.trim() !== ''
          ? { menopause_age: menopauseAge }
          : {}),
        })
      });

      const result = await response.json();
      if (!response.ok) {
        const message = Array.isArray(result.error) ? result.error.join(', ') : result.error;
        setErrorMessage(message || `Request failed (${response.status})`);
        return;
      }


      setProbabilities(result.probabilities)
      setClassifications(result.classifications)
    } catch (error) {
      console.error('Error fetching prediction:', error)
      setErrorMessage(`Error fetching prediction: ${error.message}`);
    }

  }

  return (
    <div>
      <h1>Osteoporosis Model Explorer</h1>
      <label>
        Age:
        <input type="number" value={age} onChange={(e) => setAge(e.target.value)} />
      </label>
      <br />
      <label>
        Height (cm):
        <input type="number" value={height} onChange={(e) => setHeight(e.target.value)} />
      </label>
      <br />
      <label>
        Weight (kg):
        <input type="number" value={weight} onChange={(e) => setWeight(e.target.value)} />
      </label>
      <br />
      <label>
        Menopause Age (optional):
        <input type="number" value={menopauseAge} onChange={(e) => setMenopauseAge(e.target.value)} />
      </label>
      <br />
      <label>
        Cutoff:
        <select value={cutoff} onChange={(e) => setCutoff(e.target.value)}>
          <option value="sens90">Sensitivity 90%</option>
          <option value="youden">Youden's Index</option>
        </select>
      </label>
      <br />
      <button onClick={fetchPrediction}>Fetch Prediction</button>
      {probabilities && classifications && (
        <table>
          <thead>
            <tr>
              <th scope="col">Outcome</th>
              <th scope="col">Probability</th>
              <th scope="col">Classification</th>
            </tr>
          </thead>
          <tbody>
            {outcomes.map(({ key, label }) => (
              <tr key={key}>
                <th scope="row">{label}</th>
                <td>{probabilities[key]?.[0]?.toFixed(2)}</td>
                <td>{classifications[key]?.[0]}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      {errorMessage && <p style={{ color: 'red' }}>{errorMessage}</p>}
    </div>
  );
}
export default App
