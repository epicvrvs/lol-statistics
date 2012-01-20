require 'nil/file'
require 'nil/console'

require_relative 'ChampionStats'

def loadChampionData(path)
  lines = Nil.readLines(path)
  if lines == nil
    raise 'Unable to open stats file'
  end
  champions = {}
  lines.each do |line|
    pattern = /([A-Za-z\. ]+?) (\d+) (\d+) (\d+) (V|D)/
    match = line.match(pattern)
    if match == nil
      raise "Invalid line: #{line}"
    end
    championName = match[1]
    kills = match[2].to_i
    deaths = match[3].to_i
    assists = match[4].to_i
    victorious = match[5] == 'V'
    champion = champions[championName]
    if champion == nil
      champion = ChampionStats.new(championName)
      champions[championName] = champion
    end
    champion.gather(kills, deaths, assists, victorious)
  end
  champions = champions.values.sort do |x, y|
    x.name <=> y.name
  end
  return champions
end

def decimal(input)
  return sprintf('%.1f', input)
end

def printStatistics(champions)
  table = [
    [
      'Champion',
      'W/L',
      'WLD',
      'WR',
      'K/D/A',
      'K/D',
      'K+A/D',
    ]
  ]
  champions.each do |champion|
    gain = champion.victories - champion.defeats
    wld = gain.to_s
    if gain > 0
      wld = "+#{wld}"
    end
    row = [
      champion.name,
      "#{champion.victories} - #{champion.defeats}",
      wld,
      decimal(champion.winRatio * 100) + '%',
      "#{decimal(champion.killsPerGame)}/#{decimal(champion.deathsPerGame)}/#{decimal(champion.assistsPerGame)}",
      decimal(champion.killsPerDeath),
      decimal(champion.killsAssistsPerDeath),
    ]
    table << row
  end
  Nil.printTable(table)
end
