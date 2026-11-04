type
  Tipo = enum
    tSomar, tLer, tParar

  Mensagem = object
    tipo: Tipo
    n: int
    resposta: ptr Channel[int]

var caixa: Channel[Mensagem]

proc ator() {.thread.} =
  var total = 0
  while true:
    {.cast(gcsafe).}:
      let m = caixa.recv()
      case m.tipo
      of tSomar:
        total += m.n
      of tLer:
        m.resposta[].send(total)
      of tParar:
        break

proc cliente(n: int) {.thread.} =
  {.cast(gcsafe).}:
    for i in 1 .. n:
      caixa.send(Mensagem(tipo: tSomar, n: 1))

proc main() =
  caixa.open()
  var resp: Channel[int]
  resp.open()

  var a: Thread[void]
  createThread(a, ator)

  var cs: array[4, Thread[int]]
  for i in 0 .. cs.high:
    createThread(cs[i], cliente, 1000)
  joinThreads(cs)

  caixa.send(Mensagem(tipo: tLer, resposta: addr resp))
  echo "total no ator: ", resp.recv()

  caixa.send(Mensagem(tipo: tParar))
  joinThread(a)
  resp.close()
  caixa.close()

main()
