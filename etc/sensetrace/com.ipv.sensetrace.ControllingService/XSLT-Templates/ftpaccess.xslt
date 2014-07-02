
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:it="http://xmlns.rdfinference.org/ril/issue-tracker" xmlns:rit="http://rdfs.rdfinference.org/ril/issue-tracker#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/"
	version="1.0">

	<xsl:output indent="no" />

	<xsl:param name="it-base"
		select="'http://meta.rdfinference.org/ril/issue-tracker/'" />
	<xsl:param name="it-schema"
		select="'http://rdfs.rdfinference.org/ril/issue-tracker#'" />
	<xsl:param name="it-users"
		select="'http://users.rdfinference.org/ril/issue-tracker#'" />





	<xsl:template match="System">
		<rdf:RDF>
			<xsl:call-template name="handle-item" />
		</rdf:RDF>

	</xsl:template>
	<xsl:template name="handle-item">

		<xsl:variable name="systemid">
			<xsl:value-of select="@id" />
		</xsl:variable>

		<xsl:template match="connection">
			<xsl:for-each select="//*[local-name() = 'Link']">
				<xsl:variable name="definition">
					<xsl:value-of select="*[local-name() = 'source']/@ref" />
				</xsl:variable>

				<xsl:text>&#xa;</xsl:text>
				<rdf:description rdf:about='{$systemid}'>
					<dc:ftp>
						<xsl:value-of select="$definition" />
					</dc:ftp>
				</rdf:description>
			</xsl:for-each>
			<xsl:for-each select="//*[local-name() = 'Link2']">

				<xsl:variable name="definition2">
					<xsl:value-of select="*[local-name() = 'source']/@ref" />
				</xsl:variable>
				<xsl:text>&#xa;</xsl:text>
				<rdf:description rdf:about='{$systemid}'>
					<dc:dlfolderlink>
						<xsl:value-of select="$definition2" />
					</dc:dlfolderlink>
				</rdf:description>
			</xsl:for-each>
		</xsl:template>
	</xsl:template>

</xsl:stylesheet>