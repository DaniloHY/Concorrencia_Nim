# Concorrencia em Nim

Requer Nim 2.x. O arquivo nim.cfg ativa `--threads:on` e `--mm:orc`.

    nim r 01_threads_basico.nim
    nim r 02_sincronizacao.nim
    nim r 03_corrotinas.nim
    nim r 04_event_loop.nim
    nim r 05_atores.nim
    nim r 06_outras_formas.nim

| Arquivo | Tema |
|---|---|
| 01_threads_basico.nim | createThread, memoria compartilhada, Lock, Atomic, threadvar |
| 02_sincronizacao.nim | Cond, Channel, Atomic, spawn/FlowVar |
| 03_corrotinas.nim | iteradores closure como corrotinas e escalonador cooperativo |
| 04_event_loop.nim | asyncdispatch, Future/promessas, all, timeout, poll |
| 05_atores.nim | ator implementado com Channel e threads |
| 06_outras_formas.nim | threadpool (paralelismo de dados) e multiprocessos |
