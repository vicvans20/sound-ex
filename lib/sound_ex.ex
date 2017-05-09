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
  @piezo 9
  @led 8
  @button 7

  @initial_state %{}

  import Archytax.Utilities
  use GenServer

  # Client
  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  def get_button_value(pin) do
    GenServer.call(__MODULE__, {:get_button_value, pin})
  end

  # Server
  
  def init({device_port, opts }) do
    Archytax.start_link(device_port, opts)
    {:ok, @initial_state}
  end

  def handle_call({:get_button_value, pin}, _from, state) do
    {:ok, pins} = Archytax.get_pins
    digital_value = pins[pin][:value] || 0
    {:reply, {:ok, digital_value}, state}
  end


  ######################
      # SETUP #
  ######################
  # Get board ready setup signal to setup the circuit.
  def handle_info({:archytax, {:ready, _anything}}, state ) do
    delay(2000)
    Archytax.set_pin_mode(@piezo, 3) 
    Archytax.set_pin_mode(@led, 1)

    Archytax.set_pin_mode(@button, 0) # Input mode
    Archytax.report_digital_port(@button ,1) # Report digital port value

    # Start
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
    {:ok, button_value} = SoundEx.get_button_value(@button)
    exec_loop(button_value)
    loop()
  end


  # Pressed
  def exec_loop(1) do
    beep(200)
  end

  # Not Pressed(normal loop)
  def exec_loop(0) do
    alter_loop(1)
  end

  def alter_loop(value) do
    case value do
      0 -> loop()
      1 -> silent_loop()
    end
  end
  

  defp silent_loop do
    {:ok, button_value} = SoundEx.get_button_value(@button)
     alter_loop(button_value)
     silent_loop()
  end

  def play_note({note, tempo}) do
    Archytax.Tone.play(@piezo, note, tempo)
    Archytax.set_digital_pin(@led,1)
    delay(100)
    Archytax.set_digital_pin(@led,0)
    delay(1000)
  end

  def beep(dms) do
    Archytax.analog_write(@piezo, 20)
    Archytax.set_digital_pin(@led,1)
    delay(dms)
    Archytax.analog_write(@piezo,0)
    Archytax.set_digital_pin(@led,0)
    delay(dms)
  end

end
    # Enum.each(@melody1, &play_note/1)
    # delay(2000)
    # Enum.each(@melody2, &play_note/1)
    # delay(2000)