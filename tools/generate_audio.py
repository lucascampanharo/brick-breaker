"""Gera efeitos curtos de impacto, sem silêncio inicial ou timbre de buzzer."""

import math
import random
from pathlib import Path
import struct
import wave

SAMPLE_RATE = 44100
OUTPUT = Path(__file__).resolve().parents[1] / "assets" / "audio"


def write_sound(name, samples):
    # Picos consistentes entre os três efeitos, com folga contra saturação.
    gain = 0.72 / max(abs(value) for value in samples)
    frames = [round(value * gain * 32767) for value in samples]
    with wave.open(str(OUTPUT / name), "wb") as audio:
        audio.setnchannels(1)
        audio.setsampwidth(2)
        audio.setframerate(SAMPLE_RATE)
        audio.writeframes(struct.pack("<" + "h" * len(frames), *frames))


def synthesize(name, duration, start_hz, end_hz, decay, harmonics, noise_gain=0.0):
    samples = []
    phase = 0.0
    count = round(duration * SAMPLE_RATE)
    rng = random.Random(42)
    filtered_noise = 0.0
    for index in range(count):
        t = index / SAMPLE_RATE
        progress = index / (count - 1)
        frequency = start_hz + (end_hz - start_hz) * progress
        phase += 2 * math.pi * frequency / SAMPLE_RATE
        # Ataque de 0,5 ms dá resposta imediata; a cauda termina suavemente.
        envelope = min(t / 0.0005, 1) * min((count - 1 - index) / (SAMPLE_RATE * 0.008), 1)
        envelope *= math.exp(-decay * progress)
        tone = sum(gain * math.sin(phase * harmonic) for harmonic, gain in harmonics)
        tone /= sum(gain for _, gain in harmonics)
        filtered_noise = 0.6 * filtered_noise + 0.4 * rng.uniform(-1, 1)
        transient = noise_gain * filtered_noise * math.exp(-t / 0.006)
        samples.append(envelope * (tone + transient))
    write_sound(name, samples)


def synthesize_brick_break():
    """Quebra arcade: impacto com queda rápida de tom e fragmentos brilhantes."""
    rng = random.Random(731)
    duration = 0.12
    samples = [0.0] * round(duration * SAMPLE_RATE)

    # Corpo de impacto tipo "pop", com afinação que cai nos primeiros 20 ms.
    phase = 0.0
    for index in range(len(samples)):
        t = index / SAMPLE_RATE
        frequency = 280 + 650 * math.exp(-t / 0.009)
        phase += 2 * math.pi * frequency / SAMPLE_RATE
        attack = min(t / 0.0005, 1.0)
        release = min((len(samples) - 1 - index) / (SAMPLE_RATE * 0.008), 1.0)
        body = math.sin(phase) + 0.16 * math.sin(2 * phase)
        samples[index] = 0.8 * body * attack * math.exp(-t / 0.016) * release

    # Três fragmentos curtíssimos dão uma assinatura de quebra de jogo.
    for start, frequency, strength in [(0.006, 1450, 0.23),
                                       (0.020, 1950, 0.15),
                                       (0.039, 2450, 0.08)]:
        offset = round(start * SAMPLE_RATE)
        for index in range(round(0.034 * SAMPLE_RATE)):
            t = index / SAMPLE_RATE
            envelope = min(t / 0.0004, 1) * math.exp(-t / 0.004)
            envelope *= min((0.034 - t) / 0.004, 1)
            tone = math.sin(2 * math.pi * frequency * t)
            samples[offset + index] += strength * tone * envelope

    def crack(start, length, strength, smoothing):
        count = round(length * SAMPLE_RATE)
        offset = round(start * SAMPLE_RATE)
        low = 0.0
        for index in range(min(count, len(samples) - offset)):
            t = index / SAMPLE_RATE
            noise = rng.uniform(-1, 1)
            low += smoothing * (noise - low)
            # Mistura corpo e textura áspera, com ataque abaixo de 1 ms.
            texture = 0.8 * low + 0.2 * noise
            envelope = min(t / 0.0003, 1.0) * math.exp(-5 * index / count)
            envelope *= min((count - 1 - index) / (SAMPLE_RATE * 0.003), 1.0)
            samples[offset + index] += strength * texture * envelope

    # Ruído apenas nos estalos: o corpo e os fragmentos dominam o efeito.
    crack(0.0, 0.014, 0.32, 0.45)
    crack(0.009, 0.012, 0.13, 0.6)
    crack(0.027, 0.010, 0.06, 0.5)
    write_sound("brick_hit.wav", samples)


if __name__ == "__main__":
    OUTPUT.mkdir(parents=True, exist_ok=True)
    # Impulso ascendente, bloco se desfazendo e batida oca de borracha.
    synthesize("launch.wav", 0.09, 520, 780, 4, [(1, 1), (2, 0.08)])
    synthesize_brick_break()
    synthesize("paddle_hit.wav", 0.075, 340, 210, 5, [(1, 1), (1.6, 0.10)], 0.15)
