const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const userRoutes = require('./routes/userRoutes');
const carRoutes = require('./routes/carRoutes');
const transactionRoutes = require('./routes/transactionRoutes');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

app.use('/api/users', userRoutes);
app.use('/api/cars', carRoutes);
app.use('/api', transactionRoutes);

app.get('/', (req, res) => {
	res.json({
		message: 'Dealership backend is running.',
	});
});

app.get('/api/health', (req, res) => {
	res.status(200).json({ status: 'ok' });
});

app.listen(PORT, () => {
	console.log(`Server running on port ${PORT}`);
});
