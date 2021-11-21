defmodule TelefoniaTest do
  use ExUnit.Case
  doctest Telefonia

  test "starta a aplicação" do
    assert Telefonia.start() == :ok
  end

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm!("pre.txt")
      File.rm!("pos.txt")
    end)
  end

  test "cadastra um assinante" do
    assert Telefonia.cadastrar_assinante("Bruno", "123", "12345", :prepago) ==
             {:ok, "Assinante Bruno cadastrado com sucesso"}
  end

  test "lista todos os assinantes" do
    Telefonia.cadastrar_assinante("Bruno", "123", "12345", :prepago)
    Telefonia.cadastrar_assinante("Bruno", "321", "54321", :pospago)

    assert Telefonia.listar_assinantes() == [
             %Assinante{
               chamadas: [],
               cpf: "12345",
               nome: "Bruno",
               numero: "123",
               plano: %Prepago{creditos: 0, recargas: []}
             },
             %Assinante{
               chamadas: [],
               cpf: "54321",
               nome: "Bruno",
               numero: "321",
               plano: %Pospago{valor: nil}
             }
           ]
  end

  test "lista todos os assinantes prepagos" do
    Telefonia.cadastrar_assinante("Bruno", "123", "12345", :prepago)
    Telefonia.cadastrar_assinante("Bruno", "321", "54321", :pospago)

    assert Telefonia.listar_assinantes_prepago() ==
             [
               %Assinante{
                 chamadas: [],
                 cpf: "12345",
                 nome: "Bruno",
                 numero: "123",
                 plano: %Prepago{creditos: 0, recargas: []}
               }
             ]
  end

  test "lista todos os assinantes pospagos" do
    Telefonia.cadastrar_assinante("Bruno", "123", "12345", :prepago)
    Telefonia.cadastrar_assinante("Bruno", "321", "54321", :pospago)

    assert Telefonia.listar_assinantes_pospago() ==
             [
               %Assinante{
                 chamadas: [],
                 cpf: "54321",
                 nome: "Bruno",
                 numero: "321",
                 plano: %Pospago{valor: nil}
               }
             ]
  end

  test "realiza uma recarga" do
    Telefonia.cadastrar_assinante("Bruno", "123", "12345", :prepago)

    assert Telefonia.recarga("123", DateTime.utc_now(), 30) ==
             {:ok, "Recarga atualizada com sucesso"}
  end

  test "realiza uma chamada" do
    Telefonia.cadastrar_assinante("Bruno", "123", "12345", :prepago)
    Telefonia.cadastrar_assinante("Bruno", "321", "54321", :pospago)

    Telefonia.recarga("123", DateTime.utc_now(), 30)

    assert Telefonia.fazer_chamada("123", :prepago, DateTime.utc_now(), 3) ==
             {:ok, "A chamada custou 4.35, e você tem 25.65 de créditos"}

    assert Telefonia.fazer_chamada("321", :pospago, DateTime.utc_now(), 3) ==
             {:ok, "Chamada feita com sucesso! duracao: 3 minutos"}
  end

  test "imprimir contas" do
    Telefonia.cadastrar_assinante("Bruno", "123", "12345", :prepago)
    Telefonia.cadastrar_assinante("Bruno", "321", "54321", :pospago)

    date = DateTime.utc_now()

    assert Telefonia.imprimir_contas(date.month, date.year) == :ok
  end
end
