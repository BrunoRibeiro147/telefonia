defmodule Recarga do
  @moduledoc """
  Modulo de Recargas para registrar as recargas realizadas pelos assinantes prepagos

  A função mais utilizada é a `nova/3`
  """

  defstruct data: nil, valor: nil

  @doc """
  Função de registras as recargas dos assinantes prepagos

  ## Parâmetros

  - data: Data em utc da realização da recarga
  - valor: Valor da recarga
  - numero: Número que realizou a recarga
  """

  def nova(data, valor, numero) do
    assinante = Assinante.buscar_assinante(numero, :prepago)
    plano = assinante.plano

    plano = %Prepago{
      plano
      | creditos: plano.creditos + valor,
        recargas: plano.recargas ++ [%__MODULE__{data: data, valor: valor}]
    }

    assinante = %Assinante{assinante | plano: plano}

    Assinante.atualizar(numero, assinante)

    {:ok, "Recarga atualizada com sucesso"}
  end
end
