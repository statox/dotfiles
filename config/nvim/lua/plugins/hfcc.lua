local hfcc = require('hfcc')

hfcc.setup({

    -- Api token is found on this page https://huggingface.co/settings/tokens
    -- it should be stored in ~/.huggingface/token with HF_HOME=~/.huggingface exported
    -- but I couldn't make it work so for now I'll try not to commit that by mistake
    api_token = "",
    model = "bigcode/starcoder", -- can be a model ID or an http(s) endpoint
    -- parameters that are added to the request body
    query_params = {
        max_new_tokens = 60,
        temperature = 0.2,
        top_p = 0.95,
        stop_token = "<|endoftext|>",
    },
    -- set this if the model supports fill in the middle
    fim = {
        enabled = true,
        prefix = "<fim_prefix>",
        middle = "<fim_middle>",
        suffix = "<fim_suffix>",
    },
    debounce_ms = 80,
    accept_keymap = "<Tab>",
    dismiss_keymap = "<S-Tab>",
})
