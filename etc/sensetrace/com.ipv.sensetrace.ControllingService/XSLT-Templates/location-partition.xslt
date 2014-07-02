
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


		<xsl:for-each select="//*[local-name() = 'component']">
			<xsl:variable name="definition">
				<xsl:value-of select="@name" />
			</xsl:variable>
			<xsl:variable name="mysqlid">
				<xsl:value-of select="*[local-name() = 'Quantity']/@mysqlid" />
			</xsl:variable>
	
			<xsl:text>&#xa;</xsl:text>
			<rdf:description rdf:about='{$systemid}'>
			<dc:inst rdf:resource='{$definition}'/>
			</rdf:description>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>