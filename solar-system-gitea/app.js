const path = require('path');
const fs = require('fs')
const express = require('express');
const OS = require('os');
const bodyParser = require('body-parser');
const mongoose = require("mongoose");
const app = express();
const cors = require('cors')
const serverless = require('serverless-http')


app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, '/')));
app.use(cors())

async function connectToMongo() {
    try {
        await mongoose.connect(process.env.MONGO_URI, {
            user: process.env.MONGO_USERNAME,
            pass: process.env.MONGO_PASSWORD,
            // useNewUrlParser: true,
            // useUnifiedTopology: true
        });
        console.log("MongoDB Connection Successful");
    } catch (err) {
        console.log("error!! " + err);
    }
}

connectToMongo();

var Schema = mongoose.Schema;

var dataSchema = new Schema({
    name: String,
    id: Number,
    description: String,
    image: String,
    velocity: String,
    distance: String
});
var planetModel = mongoose.model('planets', dataSchema);

app.post('/planet', async function(req, res) {
    try {
        console.log("Received Planet ID " + req.body.id);

        planetModel.insertOne({id: req.body.id, name: req.body.id})
    
        const planetData = await planetModel.findOne({ id: req.body.id });
        
        if (!planetData) {
            res.status(404).send("Ooops, We only have 9 planets and a sun. Select a number from 0 - 9");
        } else {
            res.send(planetData);
        }
    } catch (err) {
        console.error("Database error:", err);
        res.status(500).send("Error in Planet Data");
    }
});

app.get('/',   async (req, res) => {
    res.sendFile(path.join(__dirname, '/', 'index.html'));
});

app.get('/api-docs', (req, res) => {
    fs.readFile('oas.json', 'utf8', (err, data) => {
      if (err) {
        console.error('Error reading file:', err);
        res.status(500).send('Error reading file');
      } else {
        res.json(JSON.parse(data));
      }
    });
  });
  
app.get('/os',   function(req, res) {
    res.setHeader('Content-Type', 'application/json');
    res.send({
        "os": OS.hostname(),
        "env": process.env.NODE_ENV
    });
})

app.get('/live',   function(req, res) {
    res.setHeader('Content-Type', 'application/json');
    res.send({
        "status": "live"
    });
})

app.get('/ready',   function(req, res) {
    res.setHeader('Content-Type', 'application/json');
    res.send({
        "status": "ready"
    });
})

app.listen(3001, () => { console.log("Server successfully running on port - " +3000); })
module.exports = app;

//module.exports.handler = serverless(app)
