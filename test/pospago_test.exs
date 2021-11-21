defmodule PospagoTest do
  use ExUnit.Case

  doctest Pospago

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm!("pre.txt")
      File.rm!("pos.txt")
    end)
  end

  test "deve fazer uma ligacao" do
    Assinante.cadastrar("Bruno", "123", "123", :pospago)

    assert Pospago.fazer_chamada("123", DateTime.utc_now(), 5) ==
             {:ok, "Chamada feita com sucesso! duracao: 5 minutos"}
  end

  test "deve imprimir a conta do assinante" do
    Assinante.cadastrar("Bruno", "123", "123", :pospago)

    data = DateTime.utc_now()
    data_antiga = ~U[2021-10-15 16:17:14.044542Z]
    Pospago.fazer_chamada("123", data, 3)
    Pospago.fazer_chamada("123", data_antiga, 3)
    Pospago.fazer_chamada("123", data, 3)
    Pospago.fazer_chamada("123", data_antiga, 3)

    assinante = Assinante.buscar_assinante("123", :pospago)
    assert Enum.count(assinante.chamadas) == 4

    assinante = Pospago.imprimir_conta(data.month, data.year, "123")

    assert assinante.numero == "123"
    assert Enum.count(assinante.chamadas) == 2
    assert assinante.plano.valor == 8.399999999999999
    # assert Enum.count(assinante.plano.recargas) == 1
  end
end
