# Coletor de logs para deployments do Kubernetes

Este script coleta logs dos pods de um deployment específico no Kubernetes. Ele permite especificar parâmetros como o nome do deployment, o período de tempo para os logs, o namespace, e o contexto do Kubernetes. Esta ferramenta foi criada com o intuito pessoal de otimizar o tempo para obtenção de logs do cluster, possibilitando uma análise mais rápida e efetiva de casos.

## Parâmetros

- `Deployment` (`-dp`): **Nome do deployment** para o qual os logs serão coletados.
- `Since` (`-s`): **Duração para os logs**, como `'24h'`, `'15m'`.
- `Namespace` (`-ns`): **Namespace** onde o deployment está localizado.
- `Context` (`-ctx`): **Contexto do Kubernetes** a ser usado. Este parâmetro é obrigatório. Caso o valor `aws` seja fornecido, o contexto AWS configurado internamente no script será utilizado.
- `Case` (`-cs`): **Nome do estudo** para organizar os logs (opcional). Se não fornecido, os logs serão armazenados no diretório atual.

## Exemplo de Uso

```bash
.\LogsCollector.ps1 -dp meu-deployment -s 12h -ns prod -ctx aws
```

## Descrição do Script

- O script verifica se o deployment, o namespace e o contexto foram fornecidos corretamente.
- Caso o diretório de logs não exista, ele será criado com base no nome do deployment e na data atual.
- Se o parâmetro `Case` for fornecido, o nome do diretório incluirá o valor do `Case` e o contexto.
  - Para o contexto `aws`, o prefixo `[SGIOT AWS]` será usado.
  - Para outros contextos, o prefixo será baseado no nome do namespace em letras maiúsculas.
- O script coleta os logs dos pods do Kubernetes e os armazena no diretório especificado.

## Exemplo de Saída

```plaintext
------------------------------------------------------------
[2024-12-23 15:45:30] Collecting logs for pod 'meu-pod'...
Logs saved to .\[SGIOT AWS]MeuEstudo\logs_meu-deployment_2024-12-23\meu-pod-2024-12-23_15-45-30.log
------------------------------------------------------------
All logs collected in .\[SGIOT AWS]MeuEstudo\logs_meu-deployment_2024-12-23
```

## Observações

- **Contexto obrigatório**: O parâmetro `-ctx` deve ser sempre fornecido.
- **Contexto AWS**: Se o valor `aws` for especificado para o parâmetro `-ctx`, o script utilizará automaticamente o contexto AWS configurado internamente. Os arquivos de log serão prefixados com `[SGIOT AWS]`.
- **Outros contextos**: Caso um contexto diferente de `aws` seja fornecido, o prefixo dos arquivos de log será baseado no namespace especificado, em letras maiúsculas.
- **Criação do diretório**: O script verifica se o diretório de logs já existe antes de criá-lo. Se já existir, ele não será recriado.

Esta ferramenta é essencial para facilitar a coleta e organização de logs no Kubernetes, permitindo uma análise mais eficiente dos eventos nos pods.
