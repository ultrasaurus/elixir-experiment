defmodule Play do
  
  def say({:msg, msg}) do
    IO.puts "Hello " <> msg
  end
  def say(_) do
    IO.puts "Goodbye"
  end

end