/*
 * SPDX-FileCopyrightText: © 2019-2020 Nadim Kobeissi <nadim@symbolic.software>
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

// 00000000000000000000000000000000

package main

func verifyPassive(model *verifpal, valKnowledgeMap *knowledgeMap) []verifyResult {
	var verifyResults []verifyResult
	valPrincipalStates := constructPrincipalStates(model, valKnowledgeMap)
	valAttackerState := constructAttackerState(false, model, valKnowledgeMap, true)
	prettyMessage("attacker is configured as passive", 0, 0, "info")
	verifyAnalysis(model, valPrincipalStates[0], valAttackerState, 0, 0)
	return verifyResolveQueries(model, valKnowledgeMap, valPrincipalStates[0], valAttackerState, verifyResults, 0)
}
