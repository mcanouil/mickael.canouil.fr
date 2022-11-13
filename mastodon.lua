return {
  {
    Link = function (el)
      if el.target == "https://fosstodon.org/@MickaelCanouil" then
        el.attributes["rel"] = "me"
      end
      return nil
    end,
  }
}
