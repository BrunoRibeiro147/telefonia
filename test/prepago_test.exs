defmodule PrepagoTest do
  use ExUnit.Case

  doctest Prepago

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm!("pre.txt")
      File.rm!("pos.txt")
    end)
  end

  describe "Funções de ligação" do
    test "fazer uma ligação" do
      Assinante.cadastrar("Bruno", "123", "123", :prepago)
      Recarga.nova(DateTime.utc_now(), 10, "123")

      data_chamada = DateTime.utc_now()

      assert Prepago.fazer_chamada("123", data_chamada, 3) ==
               {:ok, "A chamada custou 4.35, e você tem 5.65 de créditos"}

      assinante = Assinante.buscar_assinante("123", :prepago)

      assert assinante.chamadas == [%Chamada{data: data_chamada, duracao: 3}]
    end

    test "fazer uma ligação longa e não ter créditos" do
      Assinante.cadastrar("Bruno", "123", "123", :prepago)

      assert Prepago.fazer_chamada("123", DateTime.utc_now(), 10) ==
               {:error, "você não tem créditos para fazer a ligação, realize uma recarga"}
    end
  end

  describe "Testes para impressão de contas" do
    test "deve informar valores da conta do mês" do
      Assinante.cadastrar("Bruno", "123", "123", :prepago)
      data = DateTime.utc_now()
      Recarga.nova(data, 10, "123")
      Prepago.fazer_chamada("123", data, 3)
      data_antiga = ~U[2021-10-15 16:17:14.044542Z]
      Recarga.nova(data_antiga, 10, "123")
      Prepago.fazer_chamada("123", data_antiga, 3)

      assinante = Assinante.buscar_assinante("123", :prepago)
      assert Enum.count(assinante.chamadas) == 2
      assert Enum.count(assinante.plano.recargas) == 2

      assinante = Prepago.imprimir_conta(data.month, data.year, "123")

      assert assinante.numero == "123"
      assert Enum.count(assinante.chamadas) == 1
      assert Enum.count(assinante.plano.recargas) == 1
    end
  end
end
