import std/[threadpool, osproc, times]

proc somaIntervalo(a, b: int): int =
  for i in a ..< b:
    result += i

proc main() =
  let t0 = epochTime()
  var fs: seq[FlowVar[int]]
  const total = 40_000_000
  const partes = 4
  for k in 0 ..< partes:
    fs.add spawn somaIntervalo(k * (total div partes), (k + 1) * (total div partes))
  var soma = 0
  for f in fs:
    soma += ^f
  echo "soma paralela: ", soma, " em ", int((epochTime() - t0) * 1000), "ms"

  let t1 = epochTime()
  echo "soma sequencial: ", somaIntervalo(0, total), " em ", int((epochTime() - t1) * 1000), "ms"

  let rc = execProcesses(@["echo processo A", "echo processo B", "echo processo C"], {poEvalCommand, poParentStreams})
  echo "codigo de saida: ", rc

main()
