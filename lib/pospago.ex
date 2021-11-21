defmodule Pospago do
  @moduledoc """
  Modulo de Pospago para realizar chamadas Pospagas e para impressão de contas pospaga

  A função mais utilizada é a `fazer_chamada/3`
  """

  defstruct valor: nil

  @custo_minuto 1.40

  @doc """
  Função de fazer uma chamada pospaga

  ## Parâmetros

  - numero: Numero do Assinante
  - data: Data para realização da chamada
  - duracao: Duracao da chamada
  """

  def fazer_chamada(numero, data, duracao) do
    Assinante.buscar_assinante(numero, :pospago)
    |> Chamada.registrar(data, duracao)

    {:ok, "Chamada feita com sucesso! duracao: #{duracao} minutos"}
  end

  @doc """
  Função para imprimir os dados de todas as contas

  ## Parâmetros
  - mes
  - ano
  - numero
  """
  def imprimir_conta(mes, ano, numero) do
    assinante = Contas.imprimir(mes, ano, numero, :pospago)

    valor_total =
      assinante.chamadas
      |> Enum.map(&(&1.duracao * @custo_minuto))
      |> Enum.sum()

    %Assinante{assinante | plano: %__MODULE__{valor: valor_total}}
  end
end
