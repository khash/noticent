# frozen_string_literal: true

require 'spec_helper'

describe ActAsNotified::Hooks do

  it 'should validate fetch' do
    h = ActAsNotified::Hooks.new
    expect { h.fetch(:bad) }.to raise_error(::ArgumentError)
    expect { h.fetch(:pre_channel_registration) }.not_to raise_error
  end

  it 'should run the right method' do
    chan = ActAsNotified::Channel.new(:email)
    custom_hook = double(:custom_hook)
    allow(custom_hook).to receive(:pre_channel_registration)
    allow(custom_hook).to receive(:post_channel_registration)
    h = ActAsNotified::Hooks.new
    h.add(:pre_channel_registration, custom_hook)
    h.run(:pre_channel_registration, chan)

    expect(custom_hook).to have_received(:pre_channel_registration).with(chan)
    expect(custom_hook).not_to have_received(:post_channel_registration).with(chan)
  end

  it 'runs the hooks in the right order' do
    chan = ActAsNotified::Channel
    custom_hook = double(:custom_hook)
    allow(custom_hook).to receive(:pre_channel_registration)
    allow(custom_hook).to receive(:post_channel_registration)

    ActAsNotified.configure do |config|
      config.hooks.add(:pre_channel_registration, custom_hook)
      config.hooks.add(:post_channel_registration, custom_hook)
      config.channel(:email) do |channel|
        channel.configure(String)
      end
    end

    expect(custom_hook).to have_received(:pre_channel_registration).with(chan)
    expect(custom_hook).to have_received(:post_channel_registration).with(chan)
  end

end