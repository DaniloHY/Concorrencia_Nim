import std/[locks, atomics]

var
  semTrava: int
  comTrava: int
  atomico: Atomic[int]
  trava: Lock
  idLocal {.threadvar.}: int

proc contarSemTrava(n: int) {.thread.} =
  {.cast(gcsafe).}:
    for _ in 1 .. n:
      semTrava += 1

proc contarComTrava(n: int) {.thread.} =
  {.cast(gcsafe).}:
    for _ in 1 .. n:
      withLock trava:
        comTrava += 1

proc contarAtomico(n: int) {.thread.} =
  {.cast(gcsafe).}:
    for _ in 1 .. n:
      discard atomico.fetchAdd(1)

proc usarThreadVar(id: int) {.thread.} =
  idLocal = id * 100
  echo "thread ", id, " enxerga idLocal = ", idLocal

proc executar(nome: string, p: proc (n: int) {.thread, nimcall.}, n: int) =
  var ths: array[4, Thread[int]]
  for i in 0 .. ths.high:
    createThread(ths[i], p, n)
  joinThreads(ths)
  echo nome, " concluido"

proc main() =
  initLock(trava)
  const n = 100_000
  executar("sem trava", contarSemTrava, n)
  executar("com Lock", contarComTrava, n)
  executar("com Atomic", contarAtomico, n)
  echo "esperado : ", 4 * n
  echo "sem trava: ", semTrava
  echo "com Lock : ", comTrava
  echo "atomico  : ", atomico.load

  var tv: array[3, Thread[int]]
  for i in 0 .. tv.high:
    createThread(tv[i], usarThreadVar, i + 1)
  joinThreads(tv)
  echo "main enxerga idLocal = ", idLocal
  deinitLock(trava)

main()
