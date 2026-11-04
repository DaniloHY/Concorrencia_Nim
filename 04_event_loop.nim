import std/[asyncdispatch, times]

proc tarefa(nome: string, ms: int): Future[string] {.async.} =
  echo nome, " iniciou"
  await sleepAsync(ms)
  echo nome, " terminou"
  return nome & " ok em " & $ms & "ms"

proc promessaManual(): Future[int] =
  let f = newFuture[int]("promessaManual")
  let t = sleepAsync(50)
  t.addCallback proc () =
    f.complete(7)
  return f

proc falha(): Future[int] {.async.} =
  await sleepAsync(10)
  raise newException(ValueError, "falhou de proposito")

proc principal() {.async.} =
  let t0 = epochTime()
  let rs = await all(tarefa("a", 300), tarefa("b", 200), tarefa("c", 100))
  for r in rs:
    echo r
  echo "all levou ", int((epochTime() - t0) * 1000), "ms"

  let p = await promessaManual()
  echo "promessa manual = ", p

  try:
    discard await falha()
  except ValueError as e:
    echo "erro capturado: ", e.msg

  let terminou = await withTimeout(tarefa("lenta", 1000), 100)
  echo "terminou dentro do timeout? ", terminou

  let cb = tarefa("callback", 50)
  cb.addCallback proc () =
    echo "callback recebeu: ", cb.read

  await sleepAsync(100)

waitFor principal()

let f = tarefa("poll manual", 50)
while not f.finished:
  poll(10)
echo f.read
