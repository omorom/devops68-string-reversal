# String Reversal API

Reverse any string.

## Endpoint

### GET `/reverse`

**Parameters:**
- `text` (required): Text to reverse

**Example Request:**
```
http://localhost:3011/reverse?text=hello
```

**Example Response:**
```json
{
  "input": "hello",
  "reversed": "olleh"
}
```
