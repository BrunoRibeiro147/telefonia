defmodule Prepago do
  @moduledoc """
  Modulo de Prepago para realizar chamadas prepagas e para impressão de contas prepago

  A função mais utilizada é a `fazer_chamada/3`
  """

  defstruct creditos: 0, recargas: []
  @preco_minuto 1.45

  @doc """
  Função de fazer uma chamada prepaga, a função verifica se o plano possui créditos para fazer essa chamada
  caso sim, ela retorna um :ok, caso não possua retorna um :erro

  ## Parâmetros

  - numero: Numero do Assinante
  - data: Data para realização da chamada
  - duracao: Duracao da chamada

  ## Exemplo
    iex> Telefonia.cadastrar_assinante("João", "123123", "321321", :prepago)
    iex> Telefonia.recarga("123123", DateTime.utc_now(), 10)
    iex> Prepago.fazer_chamada("123123", DateTime.utc_now(), 3)
    {:ok, "A chamada custou 4.35, e você tem 5.65 de créditos"}

    iex> Telefonia.cadastrar_assinante("João", "123123", "321321", :prepago)
    iex> Prepago.fazer_chamada("123123", DateTime.utc_now(), 3)
    {:error, "você não tem créditos para fazer a ligação, realize uma recarga"}
  """

  def fazer_chamada(numero, data, duracao) do
    assinante = Assinante.buscar_assinante(numero, :prepago)
    custo = @preco_minuto * duracao

    cond do
      custo <= assinante.plano.creditos ->
        plano = assinante.plano
        plano = %__MODULE__{plano | creditos: plano.creditos - custo}

        %Assinante{assinante | plano: plano}
        |> Chamada.registrar(data, duracao)

        {:ok, "A chamada custou #{custo}, e você tem #{plano.creditos} de créditos"}

      true ->
        {:error, "você não tem créditos para fazer a ligação, realize uma recarga"}
    end
  end

  @doc """
  Função para imprimir os dados de todas as contas

  ## Parâmetros
  - mes
  - ano
  - numero
  """

  def imprimir_conta(mes, ano, numero) do
    Contas.imprimir(mes, ano, numero, :prepago)
  end
end
