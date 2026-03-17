const express = require('express');
const app = express();

app.get('/reverse', (req, res) => {
  const { text } = req.query;
  if (!text) return res.status(400).json({ error: 'Missing text parameter' });
  
  const reversed = text.split('').reverse().join('');
  res.json({ input: text, reversed });
});

app.listen(3011, () => console.log('String Reversal API on port 3011'));
