-- local lpeg = require('lpeg')

local book = (lpeg.P('book') + lpeg.P('bk.') + lpeg.P('bks.')) / 'book'
local chapter = (lpeg.P('chapter') + lpeg.P('chap.') + lpeg.P('chaps.')) / 'chapter'
local column = (lpeg.P('column') + lpeg.P('col.') + lpeg.P('cols.')) / 'column'
local figure = (lpeg.P('figure') + lpeg.P('fig.') + lpeg.P('figs.')) / 'figure'
local folio = (lpeg.P('folio') + lpeg.P('fol.') + lpeg.P('fols.')) / 'folio'
local number = (lpeg.P('number') + lpeg.P('no.') + lpeg.P('nos.')) / 'number'
local line = (lpeg.P('line') + lpeg.P('l.') + lpeg.P('ll.')) / 'line'
local note = (lpeg.P('note') + lpeg.P('n.') + lpeg.P('nn.')) / 'note'
local opus = (lpeg.P('opus') + lpeg.P('op.') + lpeg.P('opp.')) / 'opus'
local page = (lpeg.P('page') + lpeg.P('p.') + lpeg.P('pp.')) / 'page'
local paragraph = (lpeg.P('paragraph') + lpeg.P('para.') + lpeg.P('paras.') + lpeg.P('¶¶') + lpeg.P('¶')) / 'paragraph'
local part = (lpeg.P('part') + lpeg.P('pt.') + lpeg.P('pts.')) / 'part'
local section = (lpeg.P('section') + lpeg.P('sec.') + lpeg.P('secs.') + lpeg.P('§§') + lpeg.P('§')) / 'section'
local subverbo = (lpeg.P('sub verbo') + lpeg.P('s.v.') + lpeg.P('s.vv.')) / 'sub verbo'
local verse = (lpeg.P('verse') + lpeg.P('v.') + lpeg.P('vv.')) / 'verse'
local volume = (lpeg.P('volume') + lpeg.P('vol.') + lpeg.P('vols.')) / 'volume'
local label = book + chapter + column + figure + folio + number + line + note + opus + page + paragraph + part + section + subverbo + verse + volume

local optionalwhitespace = lpeg.P(' ')^0
local whitespace = lpeg.P(' ')^1
local nonspace = lpeg.P(1) - lpeg.S(' ')
local nonbrace = lpeg.P(1) - lpeg.S('{}')

local word = nonspace^1 / 1
-- local roman = lpeg.S('IiVvXxLlCcDdMm]')^1
local number = lpeg.R('09')^1 -- + roman

local numbers = number * (optionalwhitespace * lpeg.S('-')^1 * optionalwhitespace * number)^-1
local ranges = (numbers * (optionalwhitespace * lpeg.P(',') * optionalwhitespace * numbers)^0) / 1

-- local braced_locator = lpeg.P('{') * lpeg.Cs(label + lpeg.Cc('page')) * whitespace * lpeg.C(nonbrace^1) * lpeg.P('}')
local braced_locator = lpeg.P('{') * label * whitespace * lpeg.C(nonbrace^1) * lpeg.P('}')
local braced_implicit_locator = lpeg.P('{') * lpeg.Cc('page') * lpeg.Cs(numbers) * lpeg.P('}')
local locator = braced_locator + braced_implicit_locator + (label * whitespace * ranges) + (label * whitespace * word) + (lpeg.Cc('page') * ranges)
local remainder = lpeg.C(lpeg.P(1)^0)

local suffix = lpeg.P(',')^-1 * optionalwhitespace * locator * remainder

local pseudo_locator = lpeg.P('{') * lpeg.C(nonbrace^0) * lpeg.P('}') * remainder

local module = {}

function module.parse(input, shortlabel)
  local parsed = lpeg.Ct(suffix):match(input)
  if parsed then
    return table.unpack(parsed)
  end

  parsed = lpeg.Ct(pseudo_locator):match(input)
  if parsed then
    local pt1, pt2 = table.unpack(parsed)
    return nil, nil, pt1 .. pt2
  end

  return nil, nil, input
end

return module
