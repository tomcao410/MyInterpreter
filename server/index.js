const stripe = require('stripe')('sk_test_fEWUlhy9hiuwamixG4EDWF5J00dAp2cRIb')
const express = require('express')
const cors = require('cors')
const bodyParser = require('body-parser')

const app = express()
const port = process.env.PORT || 3000

app.use(cors())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
  extented: false
}))

app.post('/charge', (req, res) => {
  const {amount, currency, token, description} = req.body
  console.log(amount, currency, token, description)
  stripe.charges.create({
    amount: +amount,
    currency,
    source: token,
    description
  }, (err, charge) => {
    if (err) res.json({code: 0})
    res.json({code: 1})
  })
})


app.listen(port, () => console.log(`Server listening on port ${port}!`))
