import React from 'react';
import './App.css';

function App() {
    const [count, setCount] = React.useState(0);

    return (
        <div className="App">
            <header className="App-header">
                <h1>Welcome to My PWA App</h1>
                <p>
                    <button type="button" onClick={() => setCount((count) => count + 1)}>
                        count is: {count}
                    </button>
                </p>
                <p>
                    Edit <code>src/App.tsx</code> and save to test HMR updates.
                </p>
            </header>
        </div>
    );
}

export default App;