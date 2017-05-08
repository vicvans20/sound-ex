defmodule SoundEx do
  @moduledoc """
  Little circuit to test the capabilities of Archytax.
  """
  # @melody1 [
  #   {:C4, 12}, {:C5, 12}, {:A3, 12}, {:A4, 12}
  # ]

  # @melody2 [
  #   {:G6,12}, {:E7,12}, {:G7,12}
  # ]

  @initial_state %{}

  import Archytax.Utilities
  use GenServer

  # Client
  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  # Server
  
  def init({device_port, opts }) do
    Archytax.start_link(device_port, opts)
    {:ok, @initial_state}
  end


  ######################
      # SETUP #
  ######################
  # Get board ready setup signal to setup the circuit.
  def handle_info({:archytax, {:ready, _anything}}, state ) do
    Archytax.set_pin_mode(9, 3)
    Archytax.set_pin_mode(8, 1)
    beep(50)
    beep(50)
    beep(50)
    delay(1000)

    spawn(fn -> loop() end)
    {:noreply, state}
  end

  # Discard unused responses from Archytax.
  def handle_info(_anything, state) do
    {:noreply, state}
  end

  # Circuit Functionality
  defp loop do
    # Enum.each(@melody1, &play_note/1)
    # delay(2000)
    # Enum.each(@melody2, &play_note/1)
    # delay(2000)
    beep(200)
    loop()
  end

  def play_note({note, tempo}) do
    Archytax.Tone.play(9, note, tempo)
    Archytax.set_digital_pin(8,1)
    delay(100)
    Archytax.set_digital_pin(8,0)
    delay(1000)
  end

  def beep(dms) do
    Archytax.analog_write(9, 20)
    Archytax.set_digital_pin(8,1)
    delay(dms)
    Archytax.analog_write(9,0)
    Archytax.set_digital_pin(8,0)
    delay(dms)
  end
end