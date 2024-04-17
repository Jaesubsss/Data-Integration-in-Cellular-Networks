
# Context-Specific Metabolic Networks Are Consistent with Experiments (GIMME)

GIMME 알고리즘의 목표는 주어진 조건 하에서 세포가 사용하는 특정한 기능을 반영하는 context-specific metabolic network를 구축하는 것입니다. 이를 위해 gene expression 데이터와 metabolic reconstruction, 그리고 하나 이상의 필수 metabolic 기능(RMF)이 입력으로 사용됩니다. 알고리즘은 이러한 입력을 활용하여 세포가 주어진 기능을 달성하기 위해 사용하는 반응의 부분집합을 예측하고, 이를 통해 생물학적으로 현실적인 metabolic network를 생성합니다.

## Abstract

미생물과 일부 포유류 genome에 대한 세포 metabolic의 reconstructions이 공개되어 있습니다. 현재까지 이러한 reconstructions들은 "genome-scale"이며, genome annotation에 의해 함축된 모든 반응과 직접적인 실험적 증거가 있는 반응을 포함하려고 노력합니다. 분명히, genome-scale의 reconstructions 중 많은 반응은 특정 조건이나 특정 세포 유형에서 활성화되지 않을 것입니다. 이러한 포괄적인 genome-scale의 reconstructions을 context-specific 네트워크로 조정하는 방법은 특정 상황에 대한 예측적인 인 실리코 모델링을 지원할 것입니다. 우리는 이러한 목표를 달성하기 위한 Gene Inactivity Moderated by Metabolism and Expression (GIMME)라는 방법을 제시합니다. GIMME 알고리즘은 양적인 유전자 expression data와 하나 이상의 예측된 metabolic 목표를 사용하여 해당 data와 가장 일치하는 context-specific reconstructions을 생성합니다. 또한 이 알고리즘은 특정 metabolic 목표에 대해 얼마나 consistency 있는 일련의 유전자 expression data인지를 나타내는 양적인 consistency 점수를 제공합니다. 우리는 이 알고리즘이 세균의 적응적 진화, metabolic engineering 균주의 합리적 설계, 그리고 인간의 골격근세포에 대한 생물학적 실험과 직관과 일치하는 결과를 생성한다는 것을 보여줍니다. 이 작업은 expression 프로파일링 data가 있는 조건에 특화된 제약 조건 기반 metabolic 모델을 생산하기 위한 진전을 나타냅니다.

## Introduction

일반적으로, genome-scale의 metabolic network는 특정 생물체의 모든 알려진 metabolic 유전자와 반응을 포함하도록 reconstruction됩니다. 이러한 reconstructions은 따라서 언제든지 생물체에서 작동하는 metabolic 반응의 superset입니다. 세포에서 어떤 효소가 활성화되는지를 결정하는 과정은 종종 제약 기반 연구에서 간과됩니다. 특히, 특정 시간에 활동할 가능성이 있는 효소들의 부분 집합을 선택하는 세포 내의 전사 조절 과정이 흥미롭습니다.

metabolic의 전사 조절에 대한 지식은 다양한 소스에서 나옵니다. low level에서는 일부 metabolic 유전자의 전사를 제어하는 규제 단백질들을 알 수 있습니다. high level에서는 유전자 expression data가 특정 시간에 무엇이 전사되고, 따라서 어떤 효소가 아마도 세포에서 활성화되어 있는지를 보여줍니다. 이러한 두 가지 유형의 지식은 주어진 조건 하에서 metabolic network를 세밀화하는 데 사용될 수 있습니다.

특정 상황에서 유전자 expression을 조절하는 방법을 연구하는 세 가지 방법이 있습니다. 

첫째, **전사 조절 네트워크(TRN)가 있는 경우**, **셀의 전사 상태를 특정 입력에 대해 계산할 수 있습니다**. 그러나 genome-scale의 TRN은 없습니다. 심지어 대장균의 경우에도 이중 간섭 실험에서 현재 약 1/4 또는 1/3 정도의 TRN만 알려져 있다고 추정되고 있습니다. ChIP-chip data 및 기타 접근 방법은 더 포괄적인 reconstruction을 가능하게 할 것입니다. 

둘째, **TRN이 없는 경우**, 생리적 목적을 달성하기 위해 생물체가 최적의 반응 세트를 선택한다는 가정에 기초한 최적화 절차가 사용되었습니다. 그러나 이러한 문제에 대해 여러 가지 해결책이 있으며, flux data가 없는 경우 내부 반응이 어떻게 사용되는지 결정할 수 있는 진짜 방법은 없습니다. 또한, 목표를 명시하는 것은 'user-bias'를 도입하며, 그러한 목표가 실제로 진정한 생리학적 상태와 관련이 없을 수 있습니다.

규제를 연구하는 세 번째 접근 방법은 사용 가능한 expression 프로파일링 data에 의존합니다. **condition이 examined되는 상황에서 이러한 data를 사용할 수 있다면, genome-scale의 reconstruction에서 고려된 ORF의 expression을 직접 조사할 수 있습니다.** metabolic network reconstruction은 다른 상태의 유전자 expression data와 결합하여 생물체의 규제 원칙을 식별하는 데 사용될 수 있습니다. 경로 기반 분석 방법은 여러 유전자의 expression 상태에 기초하여 반응 경로 전체의 사용을 예측하는 데 사용될 수 있습니다. 유전자 expression data는 이전에는 효모에 적용되어 유전자별로 어떤 반응이 비활성일 수 있는지 예측하는 데 사용되었습니다. 더 최근에는 유전자 expression data가 기본 모드로 해석되어 접근 방식이 더 기능적인 관점으로 전환되었습니다.

이러한 방법의 결과는 사용된 expression data의 품질에 의존합니다. expression data는 노이즈가 많으며, 칩의 수천 개 지점의 형광 강도를 mRNA 분자 수의 반정량적인 측정값으로 변환하는 다양한 방법은 동등한 결과를 내지 않습니다. 중요한 것은 노이즈 때문에 많은 거짓 양성을 포함하지 않고 현재 mRNA 전사체의 포괄적인 세트를 정의하는 것은 불가능합니다. 실제로, 한 마디로 말할 수 있습니다. (1) 이 몇 가지 mRNA는 세포에 거의 확실히 존재합니다. 또는 (2) 이 많은 mRNA 중 일부는 세포에 있을 수도 있습니다. 경로 기반 방법은 특정 경로에 할당된 모든 mRNA가 함께 존재하거나 없다고 가정함으로써 노이즈 문제를 피하려고 시도합니다. 이는 편향적이고 인위적인 경로 정의에 의존하며, 경로 내에서 작용하는 반응은 그 경로 외부에서도 작용할 수 있으므로 이러한 가정의 사용을 제한합니다.

우리는 여기서 expression data를 목적 함수와 결합하여 잠재적으로 노이즈가 있는 data에도 불구하고 기능적 모델을 생성합니다. 우리는 세포 내와 인간 세포 모두에서 metabolic 반응을 제한하기 위해 genome-scale의 transcriptomic data의 사용을 설명하며, context-specific metabolic network를 reconstruction하고 비교할 수 있도록 합니다. 우리는 세포의 가정된 기능적 상태와 유전자 expression data의 consistency을 양적으로 정의하여 생리학적 data와 일치함을 입증합니다. context-specific metabolic network는 다양한 세포 유형과 그에 상응하는 metabolic 과정으로 인해 인간 metabolic를 정확하게 모델링하는 데 거의 필수적일 것으로 예상됩니다.

## Results/Discussion

### GIMME Algorithm

![](./pictures/gimme1.PNG)

```
Figure 1. GIMME 알고리즘의 흐름도 도식 표현. 
        
GIMME 알고리즘은 세 가지 입력을 받습니다: 
1. gene expression mapped to reactions(또는 다른 데이터 유형) 
2. a metabolic reconstruction 
3. 하나 이상의 RMF(Required Metabolic Functionalities). 

metabolic reconstruction은 데이터 세트를 통해 매핑되며 사용할 수 없는 반응을 제거하고 reduced model을 생성합니다. 필요에 따라 반응을 다시 삽입하여 RMF(성장 및/또는 ATP 생산과 같은)를 달성합니다. 
결과적으로, 데이터와 최소한의 불일치를 가진 기능적이고 context-specific 모델이 생성됩니다. consistency 점수는 데이터와의 불일치를 양적으로 측정하여 데이터와의 최소 플럭스 합을 보여줍니다. 
```

GIMME 알고리즘은 context-specific metabolic network의 구성 방법을 의미하며, Figure 1에 설명되어 있습니다. 알고리즘의 입력으로는 다음이 필요합니다: 

1. 일련의 gene expression 데이터, 
2. genome-scale reconstruction, 
3. 세포가 달성하기로 가정되는 하나 이상의 Required
Metabolic Functionalities(RMF). 

초기 테스트 결과 (Figure에는 표시되지 않음)는 단백질체 데이터가 expression 프로파일링 데이터로 대체될 수 있음을 시사합니다. 

이 세 가지 입력이 주어지면, 알고리즘은 네트워크 내에서 활성화될 것으로 예측되는 반응 목록과, gene expression 데이터와 가정된 목표 기능 간의 불일치를 양적으로 분류하는 inconsistency scores (IS / inconsistency score)를 생성합니다.     
이 inconsistency scores는 정규화된 consistency 점수(NCS \ normalized consistency score)로 변환되어 **각 gene expression 데이터 세트가 특정 metabolic 기능과 얼마나 잘 일치하는지 상대적으로 비교할 수 있게 합니다.**    
간단히 말해, 지정된 cutoff 아래의 mRNA 전사체 수준에 해당하는 반응은 일시적으로 **비활성화**됩니다.     
세포가 이러한 반응 중 적어도 하나 없이 원하는 기능을 달성할 수 없는 경우, 선형 최적화를 사용하여 다시 활성화할 가장 일관된 반응 집합을 찾습니다. Figure 2에 설명된 것처럼, 각 반응이 재활성화되어야 하는 필요한 플럭스와 cutoff로부터의 거리의 곱으로 inconsistency scores가 계산됩니다. 작은 inconsistency scores는 데이터가 RMF와 더 일치함을 나타냅니다. 

GIMME 알고리즘은 다음의 두 단계 절차를 통해 최소한의 inconsistency scores를 가진 네트워크를 생성합니다:

(A) 각 RMF를 통한 최대 가능한 플럭스를 찾습니다(모든 반응의 사용을 허용합니다).
(B) RMF를 특정 최소 수준 이상에서 작동하도록 제한합니다(일반적으로 [A]에서 발견된 최대의 백분율) 및 양적 데이터 세트와 가장 잘 일치하는 사용 가능한 반응 집합을 식별합니다.

Part A는 플럭스 균형 분석(FBA)을 통해 달성됩니다. Part B는 다음과 같은 선형 프log래밍 문제의 해결을 포함합니다:

![](./pictures/gimmes.PNG)

![](./pictures/gimme%202.PNG)


    Figure 2. inconsistency scores의 계산. 

    각 반응의 inconsistency scores는 cutoff로부터의 편차를 반응을 통한 필요한 플럭스와 곱하여 계산됩니다. 
    이 예에서 녹색 반응은 cutoff인 12보다 높은 데이터를 가지고 있습니다(이는 매개변수입니다; 텍스트 참조). 빨간색 반응은 cutoff 아래의 데이터를 가지고 있습니다(11.4 및 8.2). 
    각 반응에 해당하는 inconsistency scores의 계산은 플럭스에 cutoff로부터의 편차를 곱하여 숫자로 표시됩니다. 이러한 값들은 모두 inconsistency scores를 증가시키며, 이는 데이터가 라크테이트에서의 성장 목표와 덜 일치한다는 것을 의미합니다.
    더 큰 필요한 플럭스와 cutoff로부터의 더 큰 편차는 모두 inconsistency scores를 증가시킵니다. 전체 inconsistency scores는 모든 개별 반응 점수의 합입니다.


수식에서, $\mathbf{x}_i$는 각 반응에 매핑된 normalized된 gene expression 데이터입니다. $\mathbf{x_{cutoff}}$는 사용자가 설정한 cutoff로, 이 cutoff를 초과하는 반응은 확실히 존재합니다. 이 cutoff를 초과하는 반응에는 inconsistency scores에 기여하지 않습니다.    
S는 반응을 열로, metabolic물질을 행으로, coefficient를 elements로 하는 coefficient 행렬입니다.    
v는 각 반응을 통한 플럭스 흐름을 양적으로 설명하는 플럭스 벡터입니다. ai와 bi는 각 반응에 대한 하한과 상한 값을 나타내며, 각각 해당 반응의 최소 및 최대 허용 플럭스를 정의합니다.    
이러한 bound는 단계 (1)에서 RMF(s)의 최대값에 따라 설정되며, 일반적으로 각 RMF에 해당하는 하한을 해당 최대값의 일부로 설정하여 수행됩니다. 대부분의 하한과 상한 값은 RMF에 해당하지 않으며, 표준 FBA 문제와 동일한 값으로 설정됩니다. 일반적으로 임의로 높거나 낮은 값으로 설정되지만, 입력 제약 조건(예: 포도당 흡수) 및 불가역 반응과 같은 경우 유한한 값으로 설정될 수도 있습니다.

위 최적화 문제는 절댓값 연산자의 존재로 인해 일반적으로 해결이 어려울 수 있지만, 이 경우 간단한 간소화로 위 문제를 표준 LP 문제로 변환합니다. 아마도 역반응이 가능한 각 반응은 두 개의 불가역 반응으로 변환되어 모든 플럭스가 양수로 제한되며, 절대값의 필요성이 제거됩니다.

일반적으로, 일부 반응에는 사용 가능한 데이터가 없을 수 있습니다. 알고리즘은 보수적인 접근 방식을 취하고 이러한 반응을 active로 지정합니다. 따라서 "gene inactivation"라는 용어가 방법 이름의 일부입니다.    
알고리즘은 이러한 반응을 데이터가 cutoff를 초과한 것처럼 다룹니다. 이는 absent 데이터에 대한 벌점을 피하기 위한 보수적인 접근 방식입니다. 데이터 부족은 결과 해석에 영향을 미칩니다. 더 나은 데이터가 주어지면 이러한 반응이 absent으로 판명될 수 있으며, 결과적으로 다른 반응을 활성화해야 할 수도 있습니다. 분명히, 제한된 데이터로 인해 결과를 신중하게 고려해야 합니다. 일반적으로 이는 대장균보다는 인간 metabolic network에서 훨씬 더 큰 문제입니다.

### Context-Specific Networks for E. coli

GIMME 알고리즘은 여러 가지 다른 조건에서 대장균을 위한 context-specific metabolic network를 생성하고 이 박테리아의 다른 균주 간의 inconsistency scores를 비교하기 위해 사용되었습니다. 거의 모든 경우에 inconsistency scores가 실험 데이터와 일치한다는 것을 보였습니다. 대장균의 다양한 성장 조건에서 gene expression 데이터가 입력 데이터로 사용되었고, 독립적인 유효성 검증 데이터는 상대적인 성장 및 생성물 분비를 설명하는 형질 데이터였습니다.

#### Strains adapted to novel substrates.

실험실에서는 대장균의 성장 속도를 향상시키기 위해 Adaptive evolution가 사용되었습니다. 대장균의 metabolic 모델은 포도당 이외의 기질을 탄소원으로 사용할 때 초기에 실험실에서 달성하는 것보다 더 나은 성장을 예측합니다. 그러나 성장을 최대화하기 위한 선택 압력이 가해지면, 실제 성장은 예측과 일치하도록 개선되는 것으로 나타났으며, 일반적으로 세포의 serial passage 후 1~2개월 후에 나타납니다. GIMME 알고리즘을 사용하여 [17]에서 설명된 세 가지 유형의 균주에 대한 context-specific metabolic network를 구축했습니다: (1) wild-type 균주, (2) 글리세롤 성장에 적응된 균주, (3) 라크테이트 성장에 적응된 균주입니다.

모델을 구성하는 데 사용된 gene expression data는 [17]에서 설명된 내용을 포함하는 CEL 파일들로 구성되었으며, GCRMA [14]를 사용하여 normalized되었습니다. 이 데이터는 reconstruction에서 gene-protein-reaction associations을 사용하여 유전자에서 반응으로 매핑되었습니다.    
임계값(xcutoff)은 12로 설정되었으며, 이는 normalized된 값이 12보다 큰 반응이 존재한다고 가정하는 것을 의미합니다. 유전자가 발현한 값이 일정 임계값 이상인 경우 해당 반응이 존재하는 것으로 간주되었습니다.    
이와 유사한 결과는 다른 임계값에서도 관찰되었습니다. 필수 metabolic 기능(RMF)은 특정 탄소원에서의 성장이었고, context-specific metabolic network는 최적 성장의 90% 이상을 유지하도록 강제되었습니다. 진화된 균주들이 거의 항상 다양한 탄소원에서 wild-type 균주보다 더 나은 성장을 하기 때문에 [19], 아홉 가지 탄소원에 대한 최적 성장을 위한 metabolic network가 구축되었습니다. 

결과는 Figure 3 (글리세롤 적응된 균주)와 Figure 4 (라크테이트 적응된 균주)에 나타나 있습니다. 이 Figure들에서 inconsistency scores를 사용하여 정규화된 consistency 점수를 계산했으며, 높은 정규화된 consistency 점수는 gene expression 프로파일이 목표와 더 일치한다는 것을 나타냅니다.    
이 Figure들은 진화된 균주들의 gene expression 상태가 거의 모든 경우에는 9가지 기질에서의 성장과 유사하게 더 일관되어 있음을 보여주며, 이는 [19]의 형질적 발견과 거의 일치합니다. 이러한 결과는 진화된 균주들이 다양한 탄소원에 대한 최적 성장을 위한 네트워크의 사용과 관련하여 wild-type 균주보다 더 일관된 gene expression 상태를 갖고 있음을 보여줍니다.

![](./pictures/gimme3.PNG)

```
Figure 3. Glycerol-evolved strain normalized consistency
scores. 

정규화된 consistency 점수는 텍스트에서 설명한대로 inconsistency scores에서 직접 계산됩니다. 더 높은 정규화된 consistency 점수는 gene expression 데이터가 RMF와 상대적으로 더 일치한다는 것을 나타냅니다. 따라서 여기에서는 글리세롤 적응 균주의 gene expression 데이터가 테스트된 각 탄소원에 대한 매우 효율적인 성장과 상대적으로 더 일치합니다. 순열 테스트에 의해 결정된 p 값은 모든 경우에서 0.01보다 작습니다.
```

![](./pictures/gimme4.PNG)

```
Figure 4. Lactate-evolved strain consistency scores. 

이 Figure은 글리세롤에 진화된 균주와 동일한 결과를 보여줍니다. 테스트된 각 탄소원에 대한 성장에 대한 정규화된 consistency 점수는 진화된 균주에서 더 높으며, 이는 진화된 균주의 gene expression 데이터가 각 탄소원에 대한 효율적인 성장과 더 일치한다는 것을 나타냅니다.
```

#### Metabolic engineering strain

metabolic engineering은 less expensive set of molecules에서 가치 있는 product를 생산하기 위해 박테리아 strain을 최적화하는 것을 목표로 합니다.    
metabolic engineering을 위한 strain의 합리적 설계는 genome 규모의 metabolic 모델과 함께 가능합니다. 대장균의 knock-out strain의 적응적 진화는 이러한 strain을 최적화하는 데 사용될 수 있습니다. 우리는 $\Delta$pta $\Delta$adhE strain의 복제체와 wild-type strain에 대한 GIMME를 사용하여 Lactate을 Glucose의 무산소 성장의 부산물로 생산하는 것을 목표로하는 실험 [21]에서 설명된 것과 같은 속도로 성장하고 Lactate 생산량을 고정시켰습니다. Figure 5에서 볼 수 있듯이, 설계된 strain는 실험 데이터가 나타내는 것과 정확히 일치하는 성장-Lactate 생산에 더 적합한 gene expression 데이터를 갖고 있습니다. 유전자 삭제 및 이후 진화는 wild-type strain보다 성장에 결합된 Lactate 생산과 더 일관된 metabolic gene expression 상태로 이어졌습니다.

우리는 이 데이터셋을 사용하여 알고리즘의 견고성을 두 가지 다른 요인에 대해 검증했습니다. 먼저, 8에서 14까지 0.1씩 증가하는 임계값에 대한 결과를 다시 계산하여 임계값을 변경하는 효과를 테스트했습니다. 우리는 모든 임계값에 대해 consistency 점수가 유의하게 다르다는 것을 발견했습니다. 일부 임계값의 경우 p 값이 다른 임계값보다 좋지 않았지만, 테스트 범위 내의 모든 임계값에 대해 p는 0.01보다 작았습니다. 

두 번째로, 잭나이프 테스트를 사용하여 알고리즘의 견고성을 확인했습니다. 우리는 100번의 반복에서 반응에 매핑된 표현 값의 5%를 무작위로 제거하고 맥락별 네트워크와 consistency 점수를 재계산했습니다. 우리는 모든 반복에서 동일한 결론에 도달했으며, 일부 경우에는 p 값이 모든 데이터를 사용할 때보다 조금 낮았습니다. 모든 경우에서 결론은 p 값이 0.02보다 작았으며, **이는 가능한 한 많은 반응이 데이터에 할당될 때 알고리즘의 통계적 성능이 더 높아져야 함을 시사합니다.**

#### Terminal electron acceptor effect on network

![](./pictures/gimme5.PNG)

```
Figure 5. Metabolic engineering strain consistency score.

Lactate를 생산하기 위해 설계된 대장균 균주의 정규화된 consistency 점수는 $\Delta$pta $\Delta$adhE 균주가 와일드 타입과 비교했을 때 Lactate의 동시 생산과 성장에 일관된 metabolic gene expression 상태를 보여줍니다. 이 더 높은 정규화된 consistency 점수는 더블 삭제 균주의 gene expression 데이터가 metabolic공학 목표와 와일드 타입 균주보다 더 일관된 것을 나타내며 실험 측정과 일치합니다.
```

대장균의 성장은 주로 산소 또는 아질산과 같은 terminal
electron acceptors의 가용성에 따라 다릅니다. 전체 21가지 다른 균주/전자 수용체 조건의 gene expression 데이터가 분석되어 산소, 무산소, 아질산 첨가 또는 미첨가 조건에서의 성장에 가장 일관된 모델을 구축했습니다. 

**기대되는 것은 주어진 조건(예: 공기중에서)에서 취한 균주 데이터가 해당 조건(다시 말해, 공기중에서)에서의 성장과 더 일치할 것이라는 것입니다.** 모든 consistency 점수 사이의 Pairwise comparison이 수행되었으며, 결과는 순서대로 공기중에서, 무산소에서, 그리고 무산소 아질산 조건에서의 성장을 나타내는 Figure 6, 7 및 8에 나타나 있습니다. 

녹색 상자는 y 축에 표시된 균주/조건이 x 축에 표시된 균주보다 성장에 더 일관되어 있는 것을 나타내며, 빨간색 상자는 그 반대를 나타냅니다. 녹색 또는 빨간색 색상의 강도는 시각화 스케일링을 위해 log2 변환 후 inconsistency scores의 차이를 나타냅니다. 검은 상자는 통계적으로 유의한 (p<0.05) 결론을 얻을 수 없음을 나타냅니다. 통계적으로 유의한 결론이 가능한 모든 경우에서 산소를 이용한 성장의 gene expression은 무산소에서의 성장보다 무산소에서의 성장에 더 일관되어 있습니다. 통계적으로 유의한 경우의 99%에서 무산소 성장에서의 gene expression은 산소를 이용한 성장보다 무산소에서의 성장에 더 일관되어 있습니다(Figure 7). 아질산을 이용한 무산소 성장에서의 경우 90%의 경우가 해당합니다(Figure 8). 예상대로, 각 조건에 대해 서로 다른 하위 반응 집합이 활성화됩니다. 이전 결과와 함께 고려하면, 이는 알고리즘에서 나타나는 consistency 점수에 대한 강력한 지원을 제공하며 긍정적인 제어를 제공합니다.

![Figure 6](./pictures/gimme6.PNG)

```
Figure 6. 유산소 조건에서 consistency의 pairwise comparisons. 

inconsistency scores의 log2 변환의 그래픽 표현입니다. 
노란색 상자는 y축의 샘플이 유산소 성장과 더 consistency 있음을 나타냅니다. 
빨간색 상자는 그 반대를 나타냅니다. 
p 값이 0.05보다 작은 차이는 비워둡니다. 
빨간색 또는 초록색의 색조는 inconsistency scores의 차이의 log2를 양적으로 나타냅니다. 
여기서 초록색과 빨간색 블록의 위치는 통계적으로 유의미한 모든 경우에 산소가 공급된 균주가 산소가 공급되지 않은 균주보다 효율적인 유산소 성장과 더 consistency 있는 gene expression을 갖고 있음을 나타냅니다.
```
![Figure 7](./pictures/gimme7.PNG)
```
Figure 7. anaerobic 조건에 대한 consistency의 pairwise comparisons.

inconsistency scores의 log2 변환의 그래픽 표현입니다. 
초록색 상자는 y축의 샘플이 anaerobic 성장과 더 consistency 있음을 나타냅니다. 
빨간색 상자는 그 반대를 나타냅니다. 
p 값이 0.05보다 작은 차이는 비워둡니다. 
빨간색 또는 초록색의 색조는 inconsistency scores의 차이의 log2를 양적으로 나타냅니다. 
초록색과 빨간색 블록의 위치는 통계적으로 유의미한 거의 모든 경우에 산소가 공급되지 않은 균주에서의 gene expression 데이터가 산소가 공급된 균주보다 효율적인 anaerobic 성장과 더 consistency 있음을 보여줍니다.

```
![Figure 8](./pictures/gimme8.PNG)
```
Figure 8. 질산 조건에 대한 consistency의 pairwise comparisons. 

inconsistency scores의 log2 변환의 그래픽 표현입니다. 
초록색 상자는 y축의 샘플이 질산 성장과 더 consistency 있음을 나타냅니다. 
빨간색 상자는 그 반대를 나타냅니다. 
p 값이 0.05보다 작은 차이는 비워둡니다. 
빨간색 또는 초록색의 색조는 inconsistency scores의 차이의 log2를 양적으로 나타냅니다. 
초록색과 빨간색 블록의 위치는 대부분의 경우에, 질산을 최종 전자 수용체로 사용하여 성장한 균주에서의 gene expression이 이 조건 하에서의 효율적인 성장과 더 consistency 있음을 보여줍니다.
```
### Context-Specific Networks for Human Cells

인간의 다양한 세포 유형은 단순한 세포 성장과 같은 단순한 목표를 공유하지 않고, 오히려 다세포 생물에 필수적인 다양한 기능을 갖추고 있습니다. 따라서 특정 세포 유형의 metabolic를 이해하기 위해서는 **해당 세포 유형에만 존재하는 반응**만을 포함한 모델이 필요합니다. 

Human Recon 1은 특정 세포 유형에서 비활성인 많은 반응을 포함하고 있습니다. 정확한 모델은 이러한 반응을 제거해야하며, **GIMME 알고리즘은 이 과정을 위한 프레임 워크를 제공합니다.** 본 연구에서는 서로 다른 조건에서의 skeletal muscle cell을 위한 first functional genomescale metabolic models를 설명합니다.

#### Data Sources

**Table 1.** Datasets used to create context-specific skeletal muscle models.

| Abbreviation | Description | Reference | GEO Accession Number |
|--------------|-------------|-----------|----------------------|
| GB           | 3 patients before and 1 year after gastric bypass surgery (vastus lateralis) | [27] | GDS2089 |
| GI           | 6 subjects before glucose/insulin infusion via clamp and 2 hours after beginning (vastus lateralis) | [28]  | GSE7146 |
|FO            | 24 subjects divided into 3 groups of eight: morbidly obese (MO), not obese (NO), and obese (O) (rectus abdominus).|[27]| GDS268|

---

Table 1 에서 보여진 것처럼 우리는 체내 skeletal muscle cells에 대한 세 가지 공개적으로 이용 가능한 gene expression data set를 사용했습니다. 이 세개의 데이터 세트는, 이전에 설명한 E.coli 데이터 세트와 마찬가지로, 원래 context-specific metabolic networks를 생성하는 것과 완전히 다른 목적으로 수집되었습니다. 그럼에도 불구하고, 이러한 데이터는 genome-scale의 metabolic network의 맥락에서 해석될 수 있습니다. 

세 데이터 세트는 모두 Affymetric(Santa Clara, CA) gene expression arrays를 사용하여 수집되었습니다. GB 데이터세트는 U133+ 2.0 배열을 사용했고, GI와 FO 데이터 세트는 U133A 배열을 사용했습니다. 배열은 비슷하지만, U133+ 2.0 배열은 U133A 배열이 제공할 수 없는 179개의 반응에 대한 신뢰할 수 있는 전사체 데이터를 제공할 수 있습니다. 이러한 arrays의 model reactions에 대한 커버리지는 Figure 9에 나와있습니다. 

특정 array type에 대한 annotation 정보가 probeset sequence가 해당 유전자 또는 밀접하게 관련된 유전자에 대해 unique하다는 것을 나타내는 경우, metabolic gege에 해당하는 각 probeset를 해당 유전자에 매핑했습니다. 여러 관련없는 유전자에 해당하는 시퀀스를 가진 probeset은 무시되었습니다. gene expression과 관련된 값은 이전에 설명한 대로 gene-protein-reaction associations를 통해 반응에 매핑되었습니다.

![](./pictures/gimme9.PNG)

```
Figure 9. Affymetrix 유전자 칩 데이터를 반응에 매핑하는 과정을 보여줍니다. 

흰색 영역의 반응은 어느 플랫폼에서도 사용 가능한 유전자 칩 데이터가 없습니다. 회색 영역의 반응은 133+ 2.0 플랫폼에서만 사용 가능한 데이터가 있습니다. 검은색 영역의 반응은 133+ 2.0과 133A 플랫폼 모두에서 사용 가능한 데이터가 있습니다. 중요한 점은 5% (179개)의 반응이 133+ 2.0 칩에만 표시되어 있으며, 이는 칩 간 점수를 증가시킬 수 있습니다. 평균 차이 점수는 340이므로, 179개의 반응의 차이는 50% 이상의 영향을 미칩니다.
```

#### Model creation and comparison

42 (6+12+24) 개의 gene expression 데이터 세트 각각에 대해 GIMME 알고리즘을 사용하여, 최적 효율성의 절반 이상에서, ATP를 생성하고 가능한 한 데이터와 일치하는 모델을 생성했습니다. 이러한 모델들은 두 모델간의 비교에서 차이가 있는 반응의 수를 찾아서 pairwise compared 되었습니다. 

평균적으로 두 모델은 340개의 반응이 다르며, 이는 global model의 반응 중 약 10퍼센ㅌ으에 해당합니다. 이러한 pairwise distance는 Figure 10에서 그래픽으로 나타납니다. 더 어두운 사각형은 밝은 사각형보다 서로 유사한 네트워크 쌍을 나타냅니다.

![](./pictures/gimme10.PNG)

```
Figure 10. sekeletal muscle models의 비교. 

이 히트맵은 각 모델 쌍의 차이 수준을 나타냅니다. 더 어두운 사각형은 더 밝은 사각형보다 서로 더 유사한 모델을 나타냅니다. 검은색 사각형(대각선상의 사각형)은 동일한 모델을 나타내며, 흰색 사각형은 가장 다른 모델 쌍을 나타냅니다. 주 대각선을 둘러싼 세 개의 어두운 블록은 각 데이터 세트 내의 샘플 간 비교입니다. 이러한 어두운 블록은 각 데이터 세트 내의 모델이 다른 데이터 세트에서 유도된 모델보다 서로 더 유사하다는 것을 보여줍니다. 특정 유전자 발현 배열 유형에서 유도된 모델은 다른 배열 유형에서 유도된 모델보다 서로 더 유사해 보입니다. 그러나 실제로 이것이 사실인지를 보여주는 데이터는 없습니다. 이는 Figure 11에서 나타나 있습니다.
```

두가지 트렌드가 즉시 나타납니다. 

첫째, 각 데이터 세트에서 유도된 metabolic 네트워크는 같은 데이터 세트에서 유도된 다른 네트워크에 더 유사합니다. 이는 대각선을 둘러싼 세개의 큰 어두운 사각형에 의해 보여집니다. 

둘째, GI와 FO 모델은 GB 모델보다 서로 더 유사한 것으로 나타납니다. 처음에는 유전자 칩이 결과에 영향을 줄 수 있다고 의심했기 때문에, U133A array에 없는 179개의 반응을 무시하고 각 모델 쌍 간의 거리를 다시 계산했습니다. 이 결과는 Figure 11에서 그래픽으로 나타납니다.     

![](./pictures/gimme11.PNG)

```
Figure 11. sekeletal muscle models의 비교, 사용된 두 종류의 유전자 칩에 모두 데이터가 있는 반응만을 사용합니다. 

이 그림은 Figure 10과 동일하지만, 그래픽으로 나타낸 거리는 두 유형의 유전자 칩에 모두 데이터가 있는 반응만을 사용하여 계산됩니다. U133+ 2.0 칩에는 표시되지만 U133A 칩에는 없는 반응의 5%는 비교에 사용되지 않습니다. 여기서는 더 이상 칩 유형에 기반한 편견을 볼 수 없으며, 대신 FO 데이터 세트가 GI 데이터 세트뿐만 아니라 GB 데이터 세트와도 유사함을 볼 수 있습니다. 칩 유형이 실험 간의 거리에 영향을 미치는 것만큼이나 거리에 영향을 미치는 것으로 보입니다. 그러나 알고리즘이 활성 또는 비활성으로 정의하는 반응에 영향을 미치는 것으로 보이는 것은 다르지 않습니다. 이는 Figure 10과 Figure 11 사이의 차이에서 확인할 수 있습니다.
```

이 Figure에서는 FO 모델이 GB 및 GI 모델 모두와 유사하지만, GI 모델이 GB 모델과 유사하지 않음을 보여줍니다. 서로 다른 유전자 발현 플랫폼에서 생성된 모델을 비교하는 것은 신중히 해야합니다. 결국 GB 모델은 데이터를 기반으로 사용하지 않을 수 있는 179개의 metabolic 반응이 있지만, GI 및 FO 모델은 데이터가 없기 때문에 사용할 수 없습니다. 

**GIMME 알고리즘은 해당 반응에 매핑된 어떤 데이터가 존재할 때에만 반응을 비활성화 합니다.** 유전자 발현 배열에서 metabolic 반응의 더 나은 커버리지는 결과적으로 생성된 모델에서 불필요한 반응의 수를 줄일 것입니다.  

#### Two significant results

해당 분석에서 비교가 어려운 모델들로부터 유도된 두 가지 중요한 결과가 나타났습니다.

첫째, 특정 환자는 위장 bypass나 포도당/인슐린 주입 전후에 자신과 자신 사이의 유사성이 다른 환자들과 비교하여 더 높은것으로 나타났습니다. GB와 GI 환자들에 대한 유사성 점수를 사용하여 두 개의 별도 그룹을 만들었습니다. 

- (A): 해당 데이터 세트 내에서 매칭된 모든 환자들의 전후 비교
- (B): 동일한 데이터 세트에서 매칭되지 않은 모든 환자들

Permutation testing 결과, A그룹의 평균 distance가 B 그룹보다 작음을 확인할 수 있었습니다.

둘째, 어떤 그룹이 다른 그룹보다, 다른것들 보다도 높은 ATP production에 있어서 더 일관적인지에 대한 consistancy scores가 조사되었습니다. 통계적으로 유의한 결과는 하나만 나타났습니다: 인슐린 주입 후 환자들이 인슐린 주입 전 환자들보다 높은 ATP 생산과 함께 더 일관되어 있었습니다. 이 결과는 기대와 일치하며, 혈류 중에 상당한 양의 포도당과 인슐린을 받은 근육 세포는 높은 ATP 생산과 더 일관된 특성을 보여주어야 합니다. 

### Conclusions

본 논문에서는 특정 유전자 발현 데이터에 대한 보장된 기능적인 metabolic 모델을 생성하고 유전자 발현 데이터와 하나 이상의 metabolic 목표간의 일치를 양적으로 평가하는 첫번째 사용 가능한 방법에 대한 세부 내용이 기술되어 있습니다. 

우리는 이 GIMME 알고리즘의 기능성을 대장균 및 인간 skeletal muscle cells의 유전자 발현 데이터와 함께 입증했습니다. 

1. 우리는 서로 다른 조건에서의 유전자 발현 데이터와 RMF 사이의 계산된 일관성이 생리학적 데이터와 일치한다는 것을 보여주었습니다.
2. 가장 일관성 있는 네트워크는 metabolic 목표와 미디어에 조건에 따라 달라집니다.
3. 인간 근육 세포에 대한 가장 일관성있는 네트워크는 전체 인간 모델보다 훨씬 적은 반응을 포함합니다.

처음에는 인간 모델에 대한 결과가 현재까지 reconstruction된 다른 생물체의 결과보다 훨씬 흥미로울 것으로 예상했습니다. 그러나 많은 수의 인간 metabolic 반응에 대한 데이터 부족으로 비교 시도가 혼란스러워졌습니다. 우리는 고려된 반응 수를 5퍼센트 줄이면 서로 다른 데이터 세트간의 명백한 차이가 바뀔 수 있음을 보였습니다.

또한, 인간 유전자 발현 데이터 세트에 복제본이 부족하고 고품질의 생물학적 제어를 얻는 것이 어려워 비교의 통계적 파워가 줄어듭니다. 대장균에 대해 제시된 결과에 대해서는 거의 모든 유전자 관련 반응에 대한 데이터, 복제본, 그리고 제어가 있기 때문에 더 높은 신뢰도를 갖습니다. 또한 대장균에서 상당수의 반응이 서로 다른 입력 조건이 제공될 때 활동이 다르다는 것을 발견했습니다. 결국, 우리는 원래 인간 세포 metabolic 분석에서 중요한 간극을 메우기 위해 고안된 도구가 실제로는 미생물 metabolic 분석에서 보다 즉각적으로 사용되는 것을 결론으로 내립니다. 

metabolic reconstruction이 점점 커지고 점점 더 많은 생물에 대해 사용 가능해지면 전역 반응 목록을 맥락별 반응 목록으로 필터링하는 도구가 매우 유용할 것입니다. 의미 있는 인간 metabolic 네트워크 분석에는 GIMME와 같은 절차가 필요할 것입니다.

## 질문과 이해

- 이 논문에서 다루는 "reconstruction"은 세포 대사의 재구성을 의미합니다. 이것은 세포의 대사 네트워크를 이해하기 위해 유전자 발현 데이터와 함께 사용되는 프로세스입니다. 보통 이러한 재구성은 특정 생물체나 세포의 전체적인 genome에 기반하여 세포 내의 모든 대사 반응을 포함하려는 노력입니다. 이러한 대사 네트워크의 재구성은 그 기본적인 반응부터 시작하여 genome annotation을 통해 암시된 모든 반응을 포함하려고 합니다. 그러나 특정 조건이나 특정 세포 유형에서 활성화되지 않는 반응이 많기 때문에 이러한 재구성은 종종 너무 방대하고 비현실적입니다. 이 논문에서는 이러한 재구성을 조건별로 조정하여 특정 상황에서의 예측 모델링을 도와주는 방법을 소개하고 있습니다.


- 이 논문에서 사용한 방식은 "high level"에서부터 차례로 "low level"까지의 방식으로 유전자 발현을 제어합니다. 구체적으로는 gene expression data를 사용하여 metabolic networks를 조정하는 방법을 사용하고 있습니다. 이 방법은 "top down" 방식에 해당합니다. 즉, gene expression data를 기반으로 하여 어떤 유전자들이 활성화되어 있는지를 직접적으로 확인하고 이를 기반으로 metabolic networks를 조정합니다. 이는 gene expression data를 이용하여 생체 내에서 발생하는 유전자의 활성화 상태를 파악하고, 이를 대사 네트워크에 적용하여 조건부 metabolic networks를 구성하는 것을 의미합니다.

- 본 논문에서 사용된 distance-based method는 유전자 발현 데이터와 대사 네트워크 간의 일관성을 측정하는 방법 중 하나입니다. 이 방법은 주어진 유전자 발현 데이터와 대사 네트워크를 비교하여 둘 사이의 "거리"를 계산합니다. 이 거리는 유전자 발현 데이터와 대사 네트워크 간의 불일치 정도를 나타냅니다. distance-based method를 사용하면 유전자 발현 데이터와 대사 네트워크 간의 일관성을 정량적으로 평가할 수 있습니다. 이를 통해 특정 조건 하에서의 대사 네트워크가 주어진 유전자 발현 패턴과 얼마나 일치하는지를 판단할 수 있습니다.