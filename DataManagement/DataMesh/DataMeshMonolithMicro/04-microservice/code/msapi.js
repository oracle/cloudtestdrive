const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const fs = require('fs');

app.use(express.json());
app.use(express.urlencoded({extended: false}));
app.use(bodyParser.json());
app.use(express.static('public'));

app.all('/med', (req, res, next) => {
   //res.send(req.body);
   const content = JSON.stringify(req.body);
   fs.writeFile('med.json', content, { flag: 'a+' }, err => {})
   next();
});

app.all('/eng', (req, res, next) => {
   //res.send(req.body);
   const content = JSON.stringify(req.body);
   fs.writeFile('eng.json', content, { flag: 'a+' }, err => {})
   next();
});

app.all('/car', (req, res, next) => {
   //res.send(req.body);
   const content = JSON.stringify(req.body);
   fs.writeFile('car.json', content, { flag: 'a+' }, err => {})
   next();
});

app.all('/pro', (req, res, next) => {
   //res.send(req.body);
   const content = JSON.stringify(req.body);
   fs.writeFile('pro.json', content, { flag: 'a+' }, err => {})
   next();
});

app.listen(9002, () => {
    console.log('Listening on port 9002...');
})

