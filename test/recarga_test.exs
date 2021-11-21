defmodule RecargaTest do
  use ExUnit.Case

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm!("pre.txt")
      File.rm!("pos.txt")
    end)
  end

  test "deve realizar uma recarga" do
    Assinante.cadastrar("Bruno", "123", "123", :prepago)

    assinante = Assinante.buscar_assinante("123", :prepago)

    data = DateTime.utc_now()

    assert Recarga.nova(data, 30, assinante.numero) ==
             {:ok, "Recarga atualizada com sucesso"}

    assinante_atualizado = Assinante.buscar_assinante("123", :prepago)

    assert assinante_atualizado.plano == %Prepago{
             creditos: 30,
             recargas: [%Recarga{data: data, valor: 30}]
           }
  end
end
