type Tarefa = iterator (): string

proc criarTarefa(nome: string, passos: int): Tarefa =
  result = iterator (): string =
    for i in 1 .. passos:
      yield nome & " executou passo " & $i

proc quadrados(n: int): iterator (): int =
  result = iterator (): int =
    for i in 1 .. n:
      yield i * i

proc main() =
  var gen = quadrados(5)
  while true:
    let v = gen()
    if finished(gen):
      break
    echo "gerador: ", v

  var fila = @[criarTarefa("A", 3), criarTarefa("B", 2), criarTarefa("C", 4)]
  while fila.len > 0:
    var proxima: seq[Tarefa]
    for i in 0 .. fila.high:
      let msg = fila[i]()
      if not finished(fila[i]):
        echo msg
        proxima.add fila[i]
    fila = proxima

main()
