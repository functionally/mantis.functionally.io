
function getValue(x) {
  return parseInt(x.value)
}

function setValue(x, y) {
  x.value = Math.round(y)
}

function getAda(x) {
  return parseInt(1000000 * x.value)
}

function setAda(x, y) {
  x.value = (y / 1000000).toFixed(6)
}

function quot(a, b) {
  return Math.floor(a / b)
}

function roundupBytesToWords(b) {
  return quot(b + 7, 8)
}

function recalculate() {
  setValue(
    adaOnlyUTxOSize,
    getValue(utxoEntrySizeWithoutVal) +
    getValue(coinSize)
  )
  if (getValue(numPIDs) == 0) {
    setValue(numAssets, 0)
    setValue(sumAssetNameLengths, 0)
  }
  if (getValue(numPIDs) > 0) {
    if (getValue(numAssets) == 0 && getValue(sumAssetNameLengths) > 0)
      setValue(numAssets, 1)
    setValue(
      size,
       6 +
       roundupBytesToWords(
         getValue(numAssets) * 12 +
         getValue(sumAssetNameLengths) +
         getValue(numPIDs) * getValue(pidSize)
       )
    )
    setAda(
      minAda,
      Math.max(
        getAda(minUTxOValue),
        quot(getAda(minUTxOValue), getValue(adaOnlyUTxOSize)) *
        (getValue(utxoEntrySizeWithoutVal) + getValue(size))
      )
    )
  } else {
    setValue(size, 0)
    setAda(minAda, getAda(minUTxOValue))
  }
}
