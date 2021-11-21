defmodule Chamada do
  @moduledoc """
  Modulo de Chamadas para registrar as chamadas realizadas pelos assinantes

  A função mais utilizada é a `registrar/3`
  """

  defstruct data: nil, duracao: nil

  @doc """
  Função registrar, para salvar a chamada feita pelo assinante

  ## Parâmetros

  - assinante: Assinante que realizou a chamada
  - data: Data em utc da realização da chamada
  - duracao: Duracao da chamada
  """

  def registrar(assinante, data, duracao) do
    assinante_atualizado = %Assinante{
      assinante
      | chamadas: assinante.chamadas ++ [%__MODULE__{data: data, duracao: duracao}]
    }

    Assinante.atualizar(assinante.numero, assinante_atualizado)
  end
end
