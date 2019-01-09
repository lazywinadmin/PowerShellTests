
# Redirect the Verbose message to the Success Output (1)
$out = invoke-restmethod -uri https://api.coinmarketcap.com/v1/ticker/bitcoin -Verbose 4>&1

# Redirect all stream to success output (1)
$out = invoke-restmethod -uri https://api.coinmarketcap.com/v1/ticker/bitcoin -Verbose *>&1

# inverse stream
# Redirect a few stream to the success output (1)
$out = invoke-restmethod -uri https://api.coinmarketcap.com/v1/ticker/bitcoin -Verbose 4>&13>&1