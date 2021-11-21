defmodule AssinanteTest do
  use ExUnit.Case

  doctest Assinante

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm!("pre.txt")
      File.rm!("pos.txt")
    end)
  end

  describe "testes responsáveis para cadastro de assinantes" do
    test "criar uma conta pre-pago" do
      assert Assinante.cadastrar("Bruno", "123", "123", :prepago) ==
               {:ok, "Assinante Bruno cadastrado com sucesso"}
    end

    test "deve retornar erro caso o assinante já esteja cadastrado" do
      Assinante.cadastrar("Bruno", "123", "123", :prepago)

      assert Assinante.cadastrar("Bruno", "123", "123", :prepago) ==
               {:error, "Esse número já existe"}
    end
  end

  describe "testes responsáveis por busca de assinantes" do
    test "busca pospago" do
      Assinante.cadastrar("Bruno", "123", "12355", :pospago)

      assert Assinante.buscar_assinante("123", :pospago) ==
               %Assinante{
                 cpf: "12355",
                 nome: "Bruno",
                 numero: "123",
                 plano: %Pospago{valor: nil}
               }
    end

    test "busca prepago" do
      Assinante.cadastrar("Rafael", "12345", "321", :prepago)

      assert Assinante.buscar_assinante("12345", :prepago) ==
               %Assinante{
                 cpf: "321",
                 nome: "Rafael",
                 numero: "12345",
                 plano: %Prepago{creditos: 0, recargas: []}
               }
    end
  end

  describe "delete" do
    test "deve deletar o assinante" do
      Assinante.cadastrar("Rafael", "12345", "321", :prepago)

      assert Assinante.deletar("12345") == {:ok, "Assinante Rafael deletado!"}
    end
  end
end
