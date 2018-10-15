# medwing

This is a Web API for storing readings from IoT thermostats and reporting a simple statistics on them.

## Prerequisites

install and run Redis in your server

## Installation

1) `git clone ...`
2) `cd medwing`
3) `bundle install`
4) `rake db:setup`
5) `rake db:seed`
6) `rails s`
7) `bundle exec sidekiq`


## Run

1) To get statistics on thermostats data URL looks like: http://localhost:3000/readings?household_token=BMVLZKAH 

2) To get readings for a partiicular thermostat URL looks like: http://localhost:3000/readings/1?household_token=BMVLZKAH

3) To create readings for a particular thermostat you can use curl looks like

curl -d "household_token=BMVLZKAH&temperature=45.4&humidity=24.5&battery_charge=1250" http://localhost:3000/readings

## Test

`rspec spec`
