import std/[locks, os, atomics, threadpool]

var
  lk: Lock
  cv: Cond
  pronto = false
  valor = 0
  canal: Channel[string]
  parar: Atomic[bool]

proc produtorCond() {.thread.} =
  {.cast(gcsafe).}:
    sleep(100)
    acquire lk
    valor = 42
    pronto = true
    release lk
    signal cv

proc consumidorCond() {.thread.} =
  {.cast(gcsafe).}:
    acquire lk
    while not pronto:
      wait(cv, lk)
    echo "consumidor recebeu ", valor
    release lk

proc produtorCanal(n: int) {.thread.} =
  {.cast(gcsafe).}:
    for i in 1 .. n:
      canal.send("mensagem " & $i)
    canal.send("fim")

proc consumidorCanal() {.thread.} =
  {.cast(gcsafe).}:
    while true:
      let m = canal.recv()
      if m == "fim":
        break
      echo "canal: ", m

proc vigia() {.thread.} =
  var voltas = 0
  while not parar.load:
    inc voltas
    sleep(10)
  echo "vigia encerrou apos ", voltas, " voltas"

proc quadrado(x: int): int =
  sleep(50)
  x * x

proc main() =
  initLock(lk)
  initCond(cv)
  var a, b: Thread[void]
  createThread(a, consumidorCond)
  createThread(b, produtorCond)
  joinThreads(a, b)
  deinitCond(cv)
  deinitLock(lk)

  canal.open()
  var p, c: Thread[void]
  var np: Thread[int]
  createThread(c, consumidorCanal)
  createThread(np, produtorCanal, 3)
  joinThread(np)
  joinThread(c)
  canal.close()

  var v: Thread[void]
  createThread(v, vigia)
  sleep(100)
  parar.store(true)
  joinThread(v)

  var fvs: seq[FlowVar[int]]
  for i in 1 .. 4:
    fvs.add spawn quadrado(i)
  for f in fvs:
    echo "flowvar: ", ^f
  sync()

main()
