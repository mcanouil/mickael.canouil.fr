return {
  {
    Link = function (el)
      if el.target == "https://fosstodon.org/@MickaelCanouil" then
        el.attributes["rel"] = "me"
        quarto.log.output(el)
      end
      return nil
    end,
  }
}
