

#https://coinmarketcap.com/api/

# Ticker
invoke-restmethod -uri https://api.coinmarketcap.com/v1/ticker/
#  with limit
invoke-restmethod -uri https://api.coinmarketcap.com/v1/ticker/?limit=10

#  to euro
invoke-restmethod -uri 'https://api.coinmarketcap.com/v1/ticker/?convert=EUR&limit=10'

# Ticker specific currentcy
invoke-restmethod -uri https://api.coinmarketcap.com/v1/ticker/bitcoin

# Ticker specific currentcy convert to eur
<#
(string) convert - return price, 24h volume, and market cap in terms of another currency. Valid values are: 
"AUD", "BRL", "CAD", "CHF", "CLP", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PKR", "PLN", "RUB", "SEK", "SGD", "THB", "TRY", "TWD", "ZAR"
#>
invoke-restmethod -uri https://api.coinmarketcap.com/v1/ticker/bitcoin/?convert=EUR
invoke-restmethod -uri https://api.coinmarketcap.com/v1/ticker/bitcoin/?convert=CAD

# Global
invoke-restmethod -uri https://api.coinmarketcap.com/v1/global/
invoke-restmethod -uri https://api.coinmarketcap.com/v1/global/?convert=EUR
