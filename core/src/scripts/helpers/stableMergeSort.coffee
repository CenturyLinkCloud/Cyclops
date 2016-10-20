# https://github.com/Two-Screen/stable

helpers.stableMergeSort = (arr, comp) ->
  exec arr.slice(), comp


# Execute the sort using the input array and a second buffer as work space.
# Returns one of those two, containing the final result.

exec = (arr, comp) ->
  if typeof comp != 'function'

    comp = (a, b) ->
      String(a).localeCompare b

  # Short-circuit when there's nothing to sort.
  len = arr.length
  if len <= 1
    return arr
  # Rather than dividing input, simply iterate chunks of 1, 2, 4, 8, etc.
  # Chunks are the size of the left or right hand in merge sort.
  # Stop when the left-hand covers all of the array.
  buffer = new Array(len)
  chk = 1
  while chk < len
    pass arr, comp, chk, buffer
    tmp = arr
    arr = buffer
    buffer = tmp
    chk *= 2
  arr


# Run a single pass with the given chunk size.

pass = (arr, comp, chk, result) ->
  len = arr.length
  i = 0
  # Step size / double chunk size.
  dbl = chk * 2
  # Bounds of the left and right chunks.
  l = undefined
  r = undefined
  e = undefined
  # Iterators over the left and right chunk.
  li = undefined
  ri = undefined
  # Iterate over pairs of chunks.
  l = 0
  while l < len
    r = l + chk
    e = r + chk
    if r > len
      r = len
    if e > len
      e = len
    # Iterate both chunks in parallel.
    li = l
    ri = r
    loop
      # Compare the chunks.
      if li < r and ri < e
        # This works for a regular `sort()` compatible comparator,
        # but also for a simple comparator like: `a > b`
        if comp(arr[li], arr[ri]) <= 0
          result[i++] = arr[li++]
        else
          result[i++] = arr[ri++]
      else if li < r
        result[i++] = arr[li++]
      else if ri < e
        result[i++] = arr[ri++]
      else
        break
    l += dbl
  return
