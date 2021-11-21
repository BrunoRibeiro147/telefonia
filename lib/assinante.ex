defmodule Assinante do
  @moduledoc """
  Modulo de assinante para cadastro de tipos de assinantes como `prepago` e `pospago`

  A função mais utilizada é a `cadastrar/4`
  """

  defstruct nome: nil, numero: nil, cpf: nil, plano: nil, chamadas: []

  @assinantes %{:prepago => "pre.txt", :pospago => "pos.txt"}

  @doc """
  Função para retornar um assinante específico, seja prepago ou pospago

  ## Parâmetros da função
   - numero: número único do assinante
   - key: atom do plano do assinante `prepago` ou `pospago`

  ## Exemplo
      iex> Assinante.cadastrar("João", "123123", "321321", :prepago)
      iex> Assinante.buscar_assinante("123123", :prepago)
      %Assinante{chamadas: [], cpf: "321321", nome: "João", numero: "123123", plano: %Prepago{creditos: 0, recargas: []}}

  """
  def buscar_assinante(numero, key \\ :all) do
    buscar(numero, key)
  end

  defp buscar(numero, :all), do: filtro(assinantes(), numero)
  defp buscar(numero, :prepago), do: filtro(busca_assinantes_prepago(), numero)
  defp buscar(numero, :pospago), do: filtro(busca_assinantes_pospago(), numero)
  defp filtro(lista, numero), do: Enum.find(lista, &(&1.numero == numero))

  @doc """
  Retorna todos os assinantes prepagos
  """
  def busca_assinantes_prepago(), do: read(:prepago)

  @doc """
  Retorna todos os assinantes pospago
  """
  def busca_assinantes_pospago(), do: read(:pospago)

  @doc """
  Retorna todos os assinantes
  """
  def assinantes(), do: read(:prepago) ++ read(:pospago)

  @doc """
  Função para cadastrar assinante seja ele `prepago` ou `pospago`

  ## Parâmetros da função

  - nome: nome do assinante
  - numero: número único e caso exista retorna um erro
  - cpf: cpf do assinante
  - plano: opcional e caso não seja informado será cadastrado como `prepago`

  ## Informações Adicionais

  - caso o número já exista ele exibirá uma mensagem erro

  ## Exemplo

      iex> Assinante.cadastrar("João", "123123", "321321", :prepago)
      {:ok, "Assinante João cadastrado com sucesso"}
  """
  def cadastrar(nome, numero, cpf, :prepago), do: cadastrar(nome, numero, cpf, %Prepago{})
  def cadastrar(nome, numero, cpf, :pospago), do: cadastrar(nome, numero, cpf, %Pospago{})

  def cadastrar(nome, numero, cpf, plano) do
    case buscar_assinante(numero) do
      nil ->
        assinante = %__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano}

        (read(pega_plano(assinante)) ++ [assinante])
        |> :erlang.term_to_binary()
        |> write(pega_plano(assinante))

        {:ok, "Assinante #{nome} cadastrado com sucesso"}

      _assinante ->
        {:error, "Esse número já existe"}
    end
  end

  @doc """
  Função para atualizar assinante

  ## Parâmetros da função

  - numero: número único
  - assinante: Struch do assinante

  ## Exemplo

      iex> Assinante.cadastrar("João", "123123", "321321", :prepago)
      iex> assinante = Assinante.buscar_assinante("123123", :prepago)
      iex> Assinante.atualizar("123123", %{assinante | nome: "João da Silva"})
      :ok
  """
  def atualizar(numero, assinante) do
    {assinante_antigo, nova_lista} = deletar_item(numero)

    case assinante.plano.__struct__ == assinante_antigo.plano.__struct__ do
      true ->
        (nova_lista ++ [assinante])
        |> :erlang.term_to_binary()
        |> write(pega_plano(assinante))

      false ->
        {:error, "Assinante não pode alterar o plano"}
    end
  end

  defp pega_plano(assinante) do
    case assinante.plano.__struct__ == Prepago do
      true -> :prepago
      false -> :pospago
    end
  end

  @doc """
  Função para deletar assinante

  ## Parâmetros da função

  - numero: número único do assinante

  ## Exemplo

      iex> Assinante.cadastrar("João", "123123", "321321", :prepago)
      iex> Assinante.deletar("123123")
      {:ok, "Assinante João deletado!"}
  """
  def deletar(numero) do
    {assinante, nova_lista} = deletar_item(numero)

    nova_lista
    |> :erlang.term_to_binary()
    |> write(assinante.plano)

    {:ok, "Assinante #{assinante.nome} deletado!"}
  end

  defp deletar_item(numero) do
    assinante = buscar_assinante(numero)

    nova_lista =
      read(pega_plano(assinante))
      |> List.delete(buscar_assinante(numero))

    {assinante, nova_lista}
  end

  defp write(lista_assinantes, plano) do
    File.write!(@assinantes[plano], lista_assinantes)
  end

  defp read(plano) do
    case Map.get(@assinantes, plano) do
      nil -> {:error, "Plano inválido"}
      val -> :erlang.binary_to_term(File.read!(val))
    end
  end
end
