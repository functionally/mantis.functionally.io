<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml">

  <xsl:strip-space elements="*" />

  <xsl:output encoding="UTF-8" method="text"/>

  <xsl:param name="cid"/>
  <xsl:param name="ts"/>

  <xsl:template match="/">

    <xsl:text>{"247426" : {"Timestamp" : "</xsl:text>
    <xsl:value-of select="$ts"/>
    <xsl:text>", "Processor": "https://mantis.functionally.io/mantis.metadata.json", "Source": ["US Energy Information Administration (EIA) Daily Energy Prices", "https://www.eia.gov/todayinenergy/prices.php", "ipfs://</xsl:text>
    <xsl:value-of select="$cid"/>
    <xsl:text><![CDATA["],
]]></xsl:text>

    <xsl:apply-templates select="//html:h1[text() = 'Daily Prices']"/>

    <xsl:text><![CDATA["Wholesale Spot Petroleum Prices" : {
]]></xsl:text>
    <xsl:apply-templates select="//html:div[@id = 's2_left']"/>
    <xsl:text><![CDATA[},
]]></xsl:text>

    <xsl:text><![CDATA["Select Spot Prices for Delivery Today" : {
]]></xsl:text>
    <xsl:apply-templates select="//html:div[@id = 'spotng2']"/>
    <xsl:text><![CDATA[}
]]></xsl:text>

    <xsl:text><![CDATA[}}
]]></xsl:text>

  </xsl:template>

  <xsl:template match="html:h1">
    <xsl:text>"Date" : "</xsl:text>
    <xsl:value-of select="normalize-space(html:span)"/>
    <xsl:text><![CDATA[",
]]></xsl:text>
  </xsl:template>

  <xsl:template match="html:div[@id = 's2_left']">

    <xsl:call-template name="petroleum">
      <xsl:with-param name="title">Crude Oil</xsl:with-param>
      <xsl:with-param name="n">3</xsl:with-param>
    </xsl:call-template>

    <xsl:text><![CDATA[,
]]></xsl:text>

    <xsl:call-template name="petroleum">
      <xsl:with-param name="title">Gasoline (RBOB)</xsl:with-param>
      <xsl:with-param name="n">3</xsl:with-param>
    </xsl:call-template>

    <xsl:text><![CDATA[,
]]></xsl:text>

    <xsl:call-template name="petroleum">
      <xsl:with-param name="title">Heating Oil</xsl:with-param>
      <xsl:with-param name="n">2</xsl:with-param>
    </xsl:call-template>

    <xsl:text><![CDATA[,
]]></xsl:text>

    <xsl:call-template name="petroleum">
      <xsl:with-param name="title">Low-Sulfur Diesel</xsl:with-param>
      <xsl:with-param name="n">3</xsl:with-param>
    </xsl:call-template>

    <xsl:text><![CDATA[,
]]></xsl:text>

    <xsl:call-template name="petroleum">
      <xsl:with-param name="title">Propane</xsl:with-param>
      <xsl:with-param name="n">2</xsl:with-param>
    </xsl:call-template>

  </xsl:template>

  <xsl:template name="petroleum">
    <xsl:param name="title"/>
    <xsl:param name="n"/>
    <xsl:apply-templates select="html:table/html:tr[html:td/normalize-space(text()[1]) = $title]"/>
    <xsl:apply-templates select="html:table/html:tr[html:td/normalize-space(text()[1]) = $title]/following-sibling::html:tr[position() &lt; $n]"/>
    <xsl:text><![CDATA[}
]]></xsl:text>
  </xsl:template>

  <xsl:template match="html:tr">
    <xsl:choose>
      <xsl:when test="html:td[@class = 's1']">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="normalize-space(html:td[@class = 's1'])"/>
        <xsl:text>" : {</xsl:text>
      </xsl:when>
      <xsl:when test="html:td[@class = 's2']">
        <xsl:text>,</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="html:td[@class = 's2']"/>
    <xsl:text>" : "</xsl:text>
    <xsl:value-of select="html:td[@class = 'd1']"/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="html:div[@id = 'spotng2']">
    <xsl:text>"Natural Gas ($/millon Btu)" : {</xsl:text>
    <xsl:apply-templates mode="naturalgas" select="html:table/html:tr[position() > 3]"/>
    <xsl:text><![CDATA[},
]]></xsl:text>
    <xsl:text>"Electricity ($/MWh)" : {</xsl:text>
    <xsl:apply-templates mode="electricity" select="html:table/html:tr[position() > 3]"/>
    <xsl:text><![CDATA[}
]]></xsl:text>
  </xsl:template>

  <xsl:template match="html:tr" mode="naturalgas">
    <xsl:if test="position() &gt; 1">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="html:td[@class = 's1']"/>
    <xsl:text>" : "</xsl:text>
    <xsl:value-of select="html:td[@class = 'd1'][1]"/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="html:tr" mode="electricity">
    <xsl:if test="position() &gt; 1">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="html:td[@class = 's1']"/>
    <xsl:text>" : "</xsl:text>
    <xsl:value-of select="html:td[@class = 'd1'][2]"/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="*"/>

</xsl:stylesheet>
