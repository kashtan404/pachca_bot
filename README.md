- [pachca_bot](#pachca_bot)
  * [Compile](#compile)
  * [Usage](#usage)
    + [Configuring alert manager](#configuring-alert-manager)
  * [Test](#test)
    + [Create your own test](#create-your-own-test)
  * [Customising messages with template](#customising-messages-with-template)
    + [Template extra functions](#template-extra-functions)
      - [Support this functions list](#support-this-functions-list)
  * [Production example](#production-example)

# pachca_bot

This bot is designed to alert messages from [alertmanager](https://github.com/prometheus/alertmanager).

Inspired by [prometheus_bot](https://github.com/inCaller/prometheus_bot).

## Compile

[GOPATH related doc](https://golang.org/doc/code.html#GOPATH).
```bash
export GOPATH="your go path"
make clean
make
```

## Usage

1. Create Webhook [Pachca Docs](https://www.pachca.com/articles/webhook)

2. Specify variables in ```config.yaml```:

    ```yml
    pachca_webhook_url: "url goes here"
    # ONLY IF YOU USING DATA FORMATTING FUNCTION, NOTE for developer: important or test fail
    time_outdata: "02/01/2006 15:04:05" 
    template_path: "template.tmpl" # ONLY IF YOU USING TEMPLATE
    time_zone: "Europe/Rome" # ONLY IF YOU USING TEMPLATE
    split_msg_byte: 4000
    ```

3. Run ```pachca_bot```. See ```pachca_bot --help``` for command line options
3. Get webhook ID - last part of webhook url (e.g. https://api.pachca.com/webhooks/***675JHGUYG4G87JH65JGV65***)

### Configuring alert manager

Alert manager configuration file:

```yml
- name: 'admins'
  webhook_configs:
  - send_resolved: True
    url: http://127.0.0.1:9087/alert/webhook_id
```

Replace ```webhook_id``` with the value you got from your bot, ***with everything inside the quotes***.
To use multiple channels just add more receivers.

## Test

To run tests with `make test` you have to:

- Create `config.yml` with a valid pachca webhook url and timezone in the project directory
- Create `pachca_bot` executable binary in the project directory
- Define webhook ID with `PACHCA_WEBHOOKID` environment variable
- Ensure port `9087` on localhost is available to bind to

```bash
export PACHCA_WEBHOOKID="YOUR PACHCA WEBHOOK ID"
make test
```
### Create your own test
When alert manager send alert to pachca bot, *only debug flag ```-d```* Pachca bot will dump json in that generate alert, in stdout.
You can copy paste this from json for your test, by creating new .json.
Test will send ```*.json``` file into ```testdata``` folder

or

```sh
PACHCA_WEBHOOKID="YOUR PACHCA WEBHOOK ID" make test
```

## Customising messages with template

This bot support [go templating language](https://golang.org/pkg/text/template/).
Use it for customising your message.

To enable template set these settings in your ```config.yaml``` or template will be skipped.

```yml
pachca_webhook_url: "url goes here" # https://api.pachca.com/webhooks
template_path: "template.tmpl" # your template file name
time_zone: "Europe/Rome" # your time zone check it out from WIKI
split_token: "|" # token used for split measure label.
```

You can also pass template path with `-t` command line argument, it has higher priority than the config option.

[WIKI List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

Best way for build your custom template is:
-    Enable bot with ```-d``` flag
-    Catch some of your alerts in json, then copy it from bot STDOUT
-    Save json in testdata/yourname.json
-    Launch ```make test```

```-d``` options will enable ```debug``` mode and template file will reload every message, else template is load once on startup.

Is provided as [default template file](testdata/default.tmpl) with all possibile variable.
Remember that pachca bot support only its own formating. Check [pachca doc here](https://www.pachca.com/articles/message-formatting) for list of aviable formating.

### Template extra functions
Template language support many different functions for text, number and data formatting.

#### Support this functions list

-   ```str_UpperCase```: Convert string to uppercase
-   ```str_LowerCase```: Convert string to lowercase
-   ```str_Title```: Convert string in Title, "title" --> "Title" fist letter become Uppercase
-   DEPRECATED  ```str_Format_Byte```: Convert number expressed in ```Byte``` to number in related measure unit. It use ```strconv.ParseFloat(..., 64)``` take look at go related doc for possible input format, usually every think '35.95e+06' is correct converted.
Example:
    -    35'000'000 [Kb] will converter to '35 Gb'
    -    89'000 [Kb] will converter to '89 Mb'
-   ```str_Format_MeasureUnit```: Convert string to scaled number and add append measure unit label. For add measure unit label you could add it in prometheus alerting rule. Example of working: 8*e10 become 80G. You cuold also start from a different scale, example kilo:"s|g|3". Check production example for complete implementation. Require ```split_token: "|"``` in conf.yaml
-   ```HasKey```: Param:dict map, key_search string Search in map if there requeted key

-    ```str_FormatDate```: Convert prometheus string date in your preferred date time format, config file param ```time_outdata``` could be used for setup your favourite format
Require more setting in your cofig.yaml
```yaml
time_zone: "Europe/Rome"
time_outdata: "02/01/2006 15:04:05"
```
[WIKI List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

## Production example

Production example contains a example of how could be a real template.

```testdata/production_example.json```
```testdata/production_example.tmpl```

It could be a base, for build a real template, or simply copy some part, check-out how to use functions.
Sysadmin usually love copy.

